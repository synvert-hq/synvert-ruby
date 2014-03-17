Synvert::Rewriter.new "use strong_parameters syntax" do
  within_files 'config/**/*.rb' do
    # remove config.active_record.whitelist_attributes = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'whitelist_attributes=' do
      remove
    end
  end

  parameters = {}
  within_files 'app/models/**/*.rb' do
    # assign and remove attr_accessible ...
    within_node type: 'class' do
      object_name = node.name.source(self).underscore
      with_node type: 'send', message: 'attr_accessible' do
        parameters[object_name] = node.arguments.map { |key| key.source(self) }.join(', ')
        remove
      end
    end
  end

  within_file 'app/controllers/**/*.rb' do
    within_node type: 'class' do
      # insert def xxx_params; ...; end
      object_name = node.name.source(self).sub('Controller', '').singularize.underscore
      if parameters[object_name]
        unless_exist_node type: 'def', name: "#{object_name}_params" do
          append """def #{object_name}_params
  params.require(:#{object_name}).permit(#{parameters[object_name]})
end"""
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
