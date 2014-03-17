require 'securerandom'

Synvert::Rewriter.new "upgrade_rails_3_2_to_4_0", "Upgrade rails from 3.2 to 4.0" do
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

  add_snippet 'convert_dynamic_finders'
  add_snippet 'strong_parameters'
end
