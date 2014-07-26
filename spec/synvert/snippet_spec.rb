require 'spec_helper'

module Synvert
  describe Snippet do
    let(:default_snippets_path) { File.join(File.dirname(__FILE__), '.synvert') }
    before { Core::Configuration.instance.set :default_snippets_path, default_snippets_path }
    after { FileUtils.rm_rf default_snippets_path }

    it 'git clones snippets' do
      Snippet.sync
      expect(File.exist?(default_snippets_path)).to be_truthy
    end

    it 'git pull snippets' do
      Snippet.sync
      Snippet.sync
      expect(File.exist?(default_snippets_path)).to be_truthy
    end
  end
end
