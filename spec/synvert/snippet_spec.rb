# frozen_string_literal: true

require 'spec_helper'

module Synvert
  describe Snippet do
    let(:snippets_path) { File.join(File.dirname(__FILE__), '.synvert-ruby') }
    let(:snippet) { Snippet.new(snippets_path) }
    after { FileUtils.rmdir(snippets_path) if File.exist?(snippets_path) }

    describe 'sync' do
      it 'git clones snippets' do
        expect(Kernel).to receive(:system).with(
          "git clone https://github.com/xinminlabs/synvert-snippets-ruby.git #{snippets_path}"
        )
        snippet.sync
      end

      it 'git pull snippets' do
        FileUtils.mkdir snippets_path
        expect(Kernel).to receive(:system).with('git checkout . && git pull --rebase')
        snippet.sync
        FileUtils.cd File.dirname(__FILE__)
      end
    end
  end
end
