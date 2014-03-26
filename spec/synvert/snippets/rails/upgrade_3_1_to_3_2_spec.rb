require 'spec_helper'

describe 'Upgrade rails from 3.1 to 3.2' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    rewriter_path = File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/rails/upgrade_3_1_to_3_2.rb')
    @rewriter = eval(File.read(rewriter_path))
    allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end

  describe 'with fakefs', fakefs: true do
    let(:gemfile_content) {"""
source 'http://rubygems.org'

gem 'rails'

gem 'sqlite3'

gem 'jquery-rails'
    """}
    let(:gemfile_rewritten_content) {"""
source 'http://rubygems.org'

gem 'rails'

gem 'sqlite3'

gem 'jquery-rails'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>=1.0.3'
end
    """}
    let(:development_content) {'''
Synvert::Application.configure do
end
    '''}
    let(:development_rewritten_content) {'''
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
    '''}
    let(:test_content) {'''
Synvert::Application.configure do
end
    '''}
    let(:test_rewritten_content) {'''
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
end
    '''}

    it 'process' do
      FileUtils.mkdir_p 'config/environments'
      File.write 'Gemfile', gemfile_content
      File.write 'config/environments/development.rb', development_content
      File.write 'config/environments/test.rb', test_content
      @rewriter.process
      expect(File.read 'Gemfile').to eq gemfile_rewritten_content
      expect(File.read 'config/environments/development.rb').to eq development_rewritten_content
      expect(File.read 'config/environments/test.rb').to eq test_rewritten_content
    end
  end
end
