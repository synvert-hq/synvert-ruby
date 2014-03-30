Synvert::Rewriter.new 'upgrade_rails_3_0_to_3_1', 'Upgrade rails from 3.0 to 3.1' do
  gem_spec 'rails', '3.0.0'

  within_file 'config/application.rb' do
    # insert config.assets.version = '1.0'
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'version=' do
      insert "config.assets.version = '1.0'"
    end
  end

  within_file 'config/application.rb' do
    # insert config.assets.enabled = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'enabled=' do
      insert 'config.assets.enabled = true'
    end
  end

  within_file 'config/application.rb' do
    # config.assets.prefix = '/assets' => config.assets.prefix = '/asset-files'
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'prefix=', arguments: ['/assets'] do
      replace_with "config.assets.prefix = '/asset-files'"
    end
  end

  within_file 'config/environments/development.rb' do
    # remove config.action_view.debug_rjs = true
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'action_view'}, message: 'debug_rjs=' do
      remove
    end
  end

  within_file 'config/environments/development.rb' do
    # insert config.assets.debug = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'debug=' do
      insert "config.assets.debug = true"
    end
  end

  within_file 'config/environments/development.rb' do
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
  end

  within_file 'config/environments/production.rb' do
    # insert config.assets.compile = false
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compile=' do
      insert "config.assets.compile = false"
    end
  end

  within_file 'config/environments/production.rb' do
    # insert config.assets.compress = true
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'assets'}, message: 'compress=' do
      insert "config.assets.compress = true"
    end
  end

  within_file 'config/environments/test.rb' do
    # insert config.static_cache_control = "public, max-age=3600"
    unless_exist_node type: 'send', receiver: {type: 'send', message: 'config'}, message: 'serve_static_assets=' do
      insert 'config.static_cache_control = "public, max-age=3600"'
    end
  end

  within_file 'config/environments/test.rb' do
    # insert config.serve_static_assets = true
    unless_exist_node type: 'send', receiver: {type: 'send', message: 'config'}, message: 'serve_static_assets=' do
      insert "config.serve_static_assets = true"
    end
  end

  add_file 'config/initializers/wrap_parameters.rb', """
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
  """.strip

  within_file 'config/initializers/session_store.rb' do
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
