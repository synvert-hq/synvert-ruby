require 'securerandom'

Synvert::Rewriter.new "upgrade_rails_3_2_to_4_0" do
  description <<-EOF
It upgrades rails from 3.2 to 4.0.

1. it removes assets group in config/application.rb.

    if defined?(Bundler)
      Bundler.require(*Rails.groups(:assets => %w(development test)))
    end
    => Bundler.require(:default, Rails.env)

2. it removes config.active_record.identity_map = true from config files.

3. it changes config.assets.compress = ... to config.assets.js_compressor = ...

4. it removes include_root_in_json from config/initializers/secret_token.rb.

    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end

5. it inserts secret_key_base to config/initializers/session_store.rb.

    Application.config.secret_key_base = '...'

6. it removes config.action_dispatch.best_standards_support = ... from config files.

7. it inserts config.eager_load = true in config/environments/production.rb.

8. it inserts config.eager_load = false in config/environments/development.rb.

9. it inserts config.eager_load = false in config/environments/test.rb.

10. it removes any code using ActionDispatch::BestStandardsSupport in config files.

11. it replaces ActionController::Base.page_cache_extension = ... with ActionController::Base.default_static_extension = ... in config files.

12. it removes Rack::Utils.escape in config/routes.rb.

    Rack::Utils.escape('こんにちは') => 'こんにちは'

13. it replaces match in config/routes.rb.

    match "/" => "root#index" => get "/" => "root#index"

14. it removes rename_index in db migrations.

15. it replaces instance method serialized_attributes with class method.

    self.serialized_attributes => self.class.serialized_attributes

16. it adds lambda for scope.

    scope :active, where(active: true) => scope :active, -> { where(active: true) }

17. it replaces ActiveRecord::Fixtures with ActiveRecord::FixtureSet.
       replaces ActiveRecord::TestCase with ActiveSupport::TestCase.
       replaces ActionController::Integration with ActionDispatch::Integration
       replaces ActionController::IntegrationTest with ActionDispatch::IntegrationTest
       replaces ActionController::PerformanceTest with ActionDispatch::PerformanceTest
       replaces ActionController::AbstractRequest with ActionDispatch::Request
       replaces ActionController::Request with ActionDispatch::Request
       replaces ActionController::AbstractResponse with ActionDispatch::Response
       replaces ActionController::Response with ActionDispatch::Response
       replaces ActionController::Routing with ActionDispatch::Routing

18. it calls another snippet convert_rails_dynamic_finder.

19. it calls another snippet strong_parameters.
  EOF

  if_gem 'rails', {gte: '3.2.0'}

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

  within_file 'config/**/*.rb' do
    # config.assets.compress = ... => config.assets.js_compressor = ...
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compress=' do
      replace_with "config.assets.js_compressor = {{arguments}}"
    end
  end

  within_file 'config/initializers/wrap_parameters.rb' do
    # remove
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    with_node type: 'block', caller: {receiver: 'ActiveSupport', message: 'on_load', arguments: [:active_record]} do
      if_only_exist_node type: 'send', receiver: 'self', message: 'include_root_in_json=', arguments: [false] do
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
    # ActionController::Base.page_cache_extension = ... => ActionController::Base.default_static_extension = ...
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

  within_files 'db/migrate/*.rb' do
    # remove rename_index ...
    with_node type: 'send', message: 'rename_index' do
      remove
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
      unless_exist_node type: 'block', caller: {type: 'send', message: 'lambda'} do
        replace_with 'scope {{arguments.first}}, -> { {{arguments.last}} }'
      end
    end
  end

  within_files '**/*.rb' do
    {'ActiveRecord::Fixtures' => 'ActiveRecord::FixtureSet',
     'ActiveRecord::TestCase' => 'ActiveSupport::TestCase',
     'ActionController::Integration' => 'ActionDispatch::Integration',
     'ActionController::IntegrationTest' => 'ActionDispatch::IntegrationTest',
     'ActionController::PerformanceTest' => 'ActionDispatch::PerformanceTest',
     'ActionController::AbstractRequest' => 'ActionDispatch::Request',
     'ActionController::Request' => 'ActionDispatch::Request',
     'ActionController::AbstractResponse' => 'ActionDispatch::Response',
     'ActionController::Response' => 'ActionDispatch::Response',
     'ActionController::Routing' => 'ActionDispatch::Routing'}.each do |deprecated, favor|
      with_node source: deprecated do
        replace_with favor
      end
    end
  end

  add_snippet 'convert_rails_dynamic_finders'
  add_snippet 'strong_parameters'

  todo <<-EOF
1. Rails 4.0 no longer supports loading plugins from vendor/plugins. You must replace any plugins by extracting them to gems and adding them to your Gemfile. If you choose not to make them gems, you can move them into, say, lib/my_plugin/* and add an appropriate initializer in config/initializers/my_plugin.rb.

2.  Make the following changes to your Gemfile.

    gem 'sass-rails', '~> 4.0.0'
    gem 'coffee-rails', '~> 4.0.0'
    gem 'uglifier', '>= 1.3.0'
  EOF
end
