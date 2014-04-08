Synvert::Rewriter.new 'upgrade_rails_3_0_to_3_1' do
  description <<-EOF
It upgrade rails from 3.0 to 3.1.

1. it enables asset pipeline.

    config.assets.enabled = true
    config.assets.version = '1.0'

2. it removes config.action_view.debug_rjs in config/environments/development.rb

3. it adds asset pipeline configs in config/environments/development.rb

    # Do not compress assets
    config.assets.compress = false

    # Expands the lines which load the assets
    config.assets.debug = true

4. it adds asset pipeline configs in config/environments/production.rb

    # Compress JavaScripts and CSS
    config.assets.compress = true

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = false

     # Generate digests for assets URLs
     config.assets.digest = true

5. it adds asset pipeline configs in config/environments/test.rb

    # Configure static asset server for tests with Cache-Control for performance
    config.serve_static_assets = true
    config.static_cache_control = "public, max-age=3600"

6. it creates config/environments/wrap_parameters.rb.

7. it replaces session_store in config/initializers/session_store.rb

    Application.session_store :cookie_store, key: '_xxx-session'
  EOF

  if_gem 'rails', {gte: '3.0.0'}

  within_file 'config/application.rb' do
    # insert config.assets.version = '1.0'
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'version=' do
      insert "config.assets.version = '1.0'"
    end

    # insert config.assets.enabled = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'enabled=' do
      insert 'config.assets.enabled = true'
    end
  end

  within_file 'config/environments/development.rb' do
    # remove config.action_view.debug_rjs = true
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'action_view'}, message: 'debug_rjs=' do
      remove
    end

    # insert config.assets.debug = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'debug=' do
      insert "config.assets.debug = true"
    end

    # insert config.assets.compress = false
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compress=' do
      insert "config.assets.compress = false"
    end
  end

  within_file 'config/environments/production.rb' do
    # insert config.assets.digest = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'digest=' do
      insert "config.assets.digest = true"
    end

    # insert config.assets.compile = false
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compile=' do
      insert "config.assets.compile = false"
    end

    # insert config.assets.compress = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compress=' do
      insert "config.assets.compress = true"
    end
  end

  within_file 'config/environments/test.rb' do
    # insert config.static_cache_control = "public, max-age=3600"
    unless_exist_node type: 'send', receiver: {type: 'send', message: 'config'}, message: 'static_cache_control=' do
      insert 'config.static_cache_control = "public, max-age=3600"'
    end

    # insert config.serve_static_assets = true
    unless_exist_node type: 'send', receiver: {type: 'send', message: 'config'}, message: 'serve_static_assets=' do
      insert "config.serve_static_assets = true"
    end
  end

  # add config/initializers/wrap_parameters.rb'
  new_code =  "# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.\n"
  new_code << "ActiveSupport.on_load(:action_controller) do\n"
  new_code << "  wrap_parameters format: [:json]\n"
  new_code << "end\n"
  new_code << "\n"
  new_code << "# Disable root element in JSON by default.\n"
  new_code << "ActiveSupport.on_load(:active_record) do\n"
  new_code << "  self.include_root_in_json = false\n"
  new_code << "end"
  add_file 'config/initializers/wrap_parameters.rb', new_code

  within_file 'config/initializers/session_store.rb' do
    # add Application.session_store :cookie_store, key: '_xxx-session'
    with_node type: 'send', receiver: {type: 'send', message: 'config'}, message: 'session_store', arguments: {first: :cookie_store} do
      session_store_key = node.receiver.receiver.source(self).split(":").first.underscore
      replace_with "{{receiver}}.session_store :cookie_store, key: '_#{session_store_key}-session'"
    end
  end

  todo <<-EOF
Make the following changes to your Gemfile.

    group :assets do
      gem 'sass-rails',   "~> 3.1.5"
      gem 'coffee-rails', "~> 3.1.1"
      gem 'uglifier',     ">= 1.0.3"
    end

    gem 'jquery-rails'
  EOF
end
