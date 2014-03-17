require 'securerandom'

class Synvert::Rewriter::Instance
  def dynamic_finder_to_hash(node, prefix)
    fields = node.message.to_s[prefix.length..-1].split("_and_")
    fields.length.times.map { |i|
      fields[i] + ": " + node.arguments[i].source(self)
    }.join(", ")
  end
end

Synvert::Rewriter.new "Upgrade rails from 3.2 to 4.0" do
  gem_spec 'rails', '3.2.0'

  within_file 'config/application.rb' do
    # if defined?(Bundler)
    #   Bundler.require(*Rails.groups(:assets => %w(development test)))
    # end
    # => Bundler.require(:default, Rails.env)
    with_node type: 'if', condition: {type: 'defined?', arguments: ['Bundler']} do
      replace_with 'Bundler.require(:default, Rails.env)'
    end
  end

  within_file 'config/**/*.rb' do
    # remove config.active_record.identity_map = true
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'identity_map=' do
      remove
    end
  end

  within_file 'config/initializers/wrap_parameters.rb' do
    # remove self.include_root_in_json = false
    with_node type: 'block', caller: {receiver: 'ActiveSupport', message: 'on_load', arguments: [':active_record']} do
      if_only_exist_node to_ast: Parser::CurrentRuby.parse('self.include_root_in_json = false') do
        remove
      end
    end
  end

  within_file 'config/initializers/secret_token.rb' do
    # insert Application.config.secret_key_base = '...'
    unless_exist_node type: 'send', message: 'secret_key_base=' do
      with_node type: 'send', message: 'secret_token=' do
        secret = SecureRandom.hex(64)
        insert_after "{{receiver}}.secret_key_base = \"#{secret}\""
      end
    end
  end

  within_files 'config/**/*.rb' do
    # remove config.action_dispatch.best_standards_support = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'action_dispatch'}, message: 'best_standards_support=' do
      remove
    end
  end

  within_files 'config/**/*.rb' do
    # remove config.active_record.whitelist_attributes = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'whitelist_attributes=' do
      remove
    end
  end

  within_file 'config/environments/production.rb' do
    # insert config.eager_load = true
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = true'
    end
  end

  within_file 'config/environments/development.rb' do
    # insert config.eager_load = false
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = false'
    end
  end

  within_file 'config/environments/test.rb' do
    # insert config.eager_load = false
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = false'
    end
  end

  within_files 'config/**/*.rb' do
    # remove config.middleware.xxx(..., ActionDispatch::BestStandardsSupport)
    with_node type: 'send', arguments: {any: 'ActionDispatch::BestStandardsSupport'} do
      remove
    end
  end

  within_files 'config/**/*.rb' do
    # remove ActionController::Base.page_cache_extension = ... => ActionController::Base.default_static_extension = ...
    with_node type: 'send', message: 'page_cache_extension=' do
      replace_with 'ActionController::Base.default_static_extension = {{arguments}}'
    end
  end

  within_file 'config/routes.rb' do
    # Rack::Utils.escape('こんにちは') => 'こんにちは'
    with_node type: 'send', receiver: 'Rack::Utils', message: 'escape' do
      replace_with '{{arguments}}'
    end
  end

  within_file 'config/routes.rb' do
    # match "/" => "root#index" => get "/" => "root#index"
    with_node type: 'send', message: 'match' do
      replace_with 'get {{arguments}}'
    end
  end

  within_files 'app/models/**/*.rb' do
    # self.serialized_attributes => self.class.serialized_attributes
    with_node type: 'send', receiver: 'self', message: 'serialized_attributes' do
      replace_with 'self.class.serialized_attributes'
    end
  end

  within_files 'app/models/**/*.rb' do
    # scope :active, where(active: true) => scope :active, -> { where(active: true) }
    with_node type: 'send', receiver: nil, message: 'scope' do
      replace_with 'scope {{arguments.first}}, -> { {{arguments.last}} }'
    end
  end

  within_files 'test/unit/**/*.rb' do
    # ActiveRecord::TestCase => ActiveSupport::TestCase
    with_node source: 'ActiveRecord::TestCase' do
      replace_with 'ActiveSupport::TestCase'
    end
  end

  within_files 'app/**/*.rb' do
    # find_all_by_... => where(...)
    with_node type: 'send', message: /find_all_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "find_all_by_")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end

  within_files 'app/**/*.rb' do
    # find_by_... => where(...).first
    with_node type: 'send', message: /find_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "find_by_")
      replace_with "{{receiver}}.where(#{hash_params}).first"
    end
  end

  within_files 'app/**/*.rb' do
    # find_last_by_... => where(...).last
    with_node type: 'send', message: /find_last_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "find_last_by_")
      replace_with "{{receiver}}.where(#{hash_params}).last"
    end
  end

  within_files 'app/**/*.rb' do
    # scoped_by_... => where(...)
    with_node type: 'send', message: /scoped_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "scoped_by_")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end

  within_files 'app/**/*.rb' do
    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node type: 'send', message: /find_or_initialize_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "find_or_initialize_by_")
      replace_with "{{receiver}}.find_or_initialize_by(#{hash_params})"
    end
  end

  within_files 'app/**/*.rb' do
    # find_or_create_by_... => find_or_create_by(...)
    with_node type: 'send', message: /find_or_create_by_(.*)/ do
      hash_params = dynamic_finder_to_hash(node, "find_or_create_by_")
      replace_with "{{receiver}}.find_or_create_by(#{hash_params})"
    end
  end

  {'ActionController::Integration' => 'ActionDispatch::Integration',
   'ActionController::IntegrationTest' => 'ActionDispatch::IntegrationTest',
   'ActionController::PerformanceTest' => 'ActionDispatch::PerformanceTest',
   'ActionController::AbstractRequest' => 'ActionDispatch::Request',
   'ActionController::Request' => 'ActionDispatch::Request',
   'ActionController::AbstractResponse' => 'ActionDispatch::Response',
   'ActionController::Response' => 'ActionDispatch::Response',
   'ActionController::Routing' => 'ActionDispatch::Routing'}.each do |deprecated, favor|
    within_files '**/*.rb' do
      with_node source: deprecated do
        replace_with favor
      end
    end
  end

  #####################
  # strong_parameters #
  #####################
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
