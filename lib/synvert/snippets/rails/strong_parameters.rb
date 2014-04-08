Synvert::Rewriter.new "strong_parameters" do
  description <<-EOF
It uses string_parameters to replace attr_accessible.

1. it removes active_record configurations.

    config.active_record.whitelist_attributes = ...
    config.active_record.mass_assignment_sanitizer = ...

2. it removes attr_accessible and attr_protected code in models.

3. it adds xxx_params in controllers

    def xxx_params
      params.require(:xxx).permit(...)
    end

4. it replaces params[:xxx] with xxx_params.

    params[:xxx] => xxx_params
  EOF

  within_files 'config/**/*.rb' do
    # remove config.active_record.whitelist_attributes = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'whitelist_attributes=' do
      remove
    end

    # remove config.active_record.mass_assignment_sanitizer = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'mass_assignment_sanitizer=' do
      remove
    end
  end

  attributes = {}
  within_file 'db/schema.rb' do
    within_node type: 'block', caller: {type: 'send', message: 'create_table'} do
      object_name = eval(node.caller.arguments.first.source(self)).singularize
      attributes[object_name] = []
      with_node type: 'send', receiver: 't' do
        attribute_name = eval(node.arguments.first.source(self)).to_sym
        attributes[object_name] << attribute_name
      end
    end
  end

  parameters = {}
  within_files 'app/models/**/*.rb' do
    # assign and remove attr_accessible ...
    within_node type: 'class' do
      object_name = node.name.source(self).underscore
      with_node type: 'send', message: 'attr_accessible' do
        parameters[object_name] = node.arguments.map { |key| eval(key.source(self)) }
        remove
      end
    end

    # assign and remove attr_protected ...
    within_node type: 'class' do
      object_name = node.name.source(self).underscore
      with_node type: 'send', message: 'attr_protected' do
        parameters[object_name] = attributes[object_name] - node.arguments.map { |key| eval(key.source(self)) }
        remove
      end
    end
  end

  within_file 'app/controllers/**/*.rb' do
    within_node type: 'class' do
      object_name = node.name.source(self).sub('Controller', '').singularize.underscore
      if_exist_node type: 'send', receiver: 'params', message: '[]', arguments: [object_name.to_sym] do
        if parameters[object_name]
          # append def xxx_params; ...; end
          permit_params = ":" + parameters[object_name].join(", :")
          unless_exist_node type: 'def', name: "#{object_name}_params" do
            new_code =  "def #{object_name}_params\n"
            new_code << "  params.require(:#{object_name}).permit(#{permit_params})\n"
            new_code << "end"
            append new_code
          end

          # params[:xxx] => xxx_params
          with_node type: 'send', receiver: 'params', message: '[]' do
            object_name = eval(node.arguments.first.source(self)).to_s
            if parameters[object_name]
              replace_with "#{object_name}_params"
            end
          end
        end
      end
    end
  end
end
