require 'spec_helper'

module Synvert
  describe Snippet do
    let(:snippets_path) { File.join(File.dirname(__FILE__), '.synvert') }
    let(:snippet) { Snippet.new(snippets_path) }
    after { FileUtils.rmdir(snippets_path) if File.exist?(snippets_path) }

    describe 'sync' do
      it 'git clones snippets' do
        expect(Kernel).to receive(:system).with(
          "git clone https://github.com/xinminlabs/synvert-snippets.git #{snippets_path}"
        )
        snippet.sync
      end

      it 'git pull snippets' do
        FileUtils.mkdir snippets_path
        expect(Kernel).to receive(:system).with('git pull --rebase')
        snippet.sync
        FileUtils.cd File.dirname(__FILE__)
      end
    end

    describe 'fetch_core_version' do
      it 'gets remote version' do
        stub_request(:get, 'https://rubygems.org/api/v1/versions/synvert-core.json').to_return(
          body: '[{"number":"0.4.2"}]'
        )
        expect(snippet.fetch_core_version).to eq '0.4.2'
      end
    end
  end
end
