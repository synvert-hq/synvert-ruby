require 'spec_helper'

module Synvert
  describe Snippet do
    describe "sync" do
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

    describe "fetch_core_version" do
      it 'gets remote version' do
        stub_request(:get, "https://rubygems.org/api/v1/versions/synvert-core.json").
          to_return(:body => '[{"number":"0.4.2"}]')
        expect(Snippet.fetch_core_version).to eq "0.4.2"
      end
    end
  end
end
