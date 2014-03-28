require 'spec_helper'

describe 'Upgrade rails from 3.0 to 3.1' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    rewriter_path = File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/rails/upgrade_3_0_to_3_1.rb')
    @rewriter = eval(File.read(rewriter_path))
    allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end

  describe 'with fakefs', fakefs: true do
    let(:application_content) {"""
Synvert::Application.configure do
  config.assets.prefix = '/assets'
end
    """}
    let(:application_rewritten_content) {"""
Synvert::Application.configure do
  config.assets.enabled = true
  config.assets.version = '1.0'
  config.assets.prefix = '/asset-files'
end
    """}
    let(:development_content) {"""
Synvert::Application.configure do
  config.action_view.debug_rjs = true
end
    """}
    let(:development_rewritten_content) {"""
Synvert::Application.configure do
  config.assets.compress = false
  config.assets.debug = true
end
    """}
    let(:production_content) {"""
Synvert::Application.configure do
end
    """}
    let(:production_rewritten_content) {"""
Synvert::Application.configure do
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
end
    """}
    let(:test_content) {"""
Synvert::Application.configure do
end
    """}
    let(:test_rewritten_content) {'''
Synvert::Application.configure do
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"
end
    '''}
    let(:wrap_parameters_rewritten_content) {"""
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
    """.strip}
    let(:session_store_content) {"""
Synvert::Application.config.session_store :cookie_store, key: 'somethingold'
    """}
    let(:session_store_rewritten_content) {"""
Synvert::Application.config.session_store :cookie_store, key: '_synvert-session'
    """}

    it 'process' do
      FileUtils.mkdir_p 'config/environments'
      FileUtils.mkdir_p 'config/initializers'
      File.write 'config/application.rb', application_content
      File.write 'config/environments/development.rb', development_content
      File.write 'config/environments/production.rb', production_content
      File.write 'config/environments/test.rb', test_content
      File.write 'config/initializers/session_store.rb', session_store_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'config/environments/production.rb').to eq production_rewritten_content
      expect(File.read 'config/environments/test.rb').to eq test_rewritten_content
      expect(File.read 'config/initializers/wrap_parameters.rb').to eq wrap_parameters_rewritten_content
      expect(File.read 'config/initializers/session_store.rb').to eq session_store_rewritten_content
    end
  end
end
