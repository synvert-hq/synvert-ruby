# frozen_string_literal: true

require 'spec_helper'

module Synvert
  RSpec.describe Command do
    let(:snippets_path) { File.join(File.dirname(__FILE__), '.synvert-ruby') }
    before { allow(described_class).to receive(:default_snippets_home).and_return(snippets_path) }
    before { FileUtils.rm_rf(snippets_path) if Dir.exist?(snippets_path) }
    after { FileUtils.rm_rf(snippets_path) if Dir.exist?(snippets_path) }

    describe '.sync_snippets' do
      it 'git clones snippets' do
        expect(Kernel).to receive(:system).with(
          "git clone https://github.com/synvert-hq/synvert-snippets-ruby.git #{snippets_path}"
        )
        described_class.sync_snippets
      end

      it 'git pull snippets' do
        FileUtils.mkdir snippets_path
        expect(Kernel).to receive(:system).with('git checkout . && git pull --rebase')
        described_class.sync_snippets
        FileUtils.cd File.dirname(__FILE__)
      end
    end

    describe '.read_rewriters' do
      before do
        FileUtils.mkdir_p(File.join(snippets_path, 'lib'))
        File.write(File.join(snippets_path, 'lib', 'foo_rewriter.rb'), <<~EOS)
          Synvert::Rewriter.new 'ruby', 'foo_rewriter' do
          end
        EOS
        File.write(File.join(snippets_path, 'lib', 'bar_rewriter.rb'), <<~EOS)
          Synvert::Rewriter.new 'ruby', 'bar_rewriter' do
          end
        EOS
      end

      it 'requires all .rb files in the lib directory of the snippets home' do
        described_class.read_rewriters
        expect(Synvert::Rewriter.fetch('ruby', 'foo_rewriter')).to be_a(Synvert::Rewriter)
        expect(Synvert::Rewriter.fetch('ruby', 'bar_rewriter')).to be_a(Synvert::Rewriter)
      end
    end

    describe '.read_helpers' do
      before do
        FileUtils.mkdir_p(File.join(snippets_path, 'lib', 'helpers'))
        File.write(File.join(snippets_path, 'lib', 'helpers', 'foo_helper.rb'), <<~EOS)
          Synvert::Helper.new 'foo_helper' do
          end
        EOS
        File.write(File.join(snippets_path, 'lib', 'helpers', 'bar_helper.rb'), <<~EOS)
          Synvert::Helper.new 'bar_helper' do
          end
        EOS
      end

      it 'requires all .rb files in the lib/helpers directory of the snippets home' do
        described_class.read_helpers
        expect(Synvert::Helper.fetch('foo_helper')).to be_a(Synvert::Helper)
        expect(Synvert::Helper.fetch('bar_helper')).to be_a(Synvert::Helper)
      end
    end

    describe '.available_rewriters' do
      it 'requires all .rb files in the lib directory of the snippets home' do
        Synvert::Rewriter.new 'ruby', 'foo_rewriter' do
        end
        Synvert::Rewriter.new 'ruby', 'bar_rewriter' do
        end
        expect(described_class.available_rewriters).to match_array [
          { description: nil, group: "ruby", name: "foo_rewriter", sub_snippets: [] },
          { description: nil, group: "ruby", name: "bar_rewriter", sub_snippets: [] }
        ]
      end
    end

    describe '.generate_snippet' do
      it 'generates both snippet code and test code' do
        described_class.generate_snippet('ruby/foobar')
        expect(File.read('lib/ruby/foobar.rb')).to eq <<~EOF
          # frozen_string_literal: true

          Synvert::Rewriter.new 'ruby', 'foobar' do
            configure(parser: Synvert::PRISM_PARSER)

            description <<~EOS
              It converts Foo to Bar

              ```ruby
              Foo
              ```

              =>

              ```ruby
              Bar
              ```
            EOS

            within_files '**/*.rb' do
              with_node type: 'const', to_source: 'Foo' do
                replace_with 'Bar'
              end
            end
          end
        EOF
        expect(File.read('spec/ruby/foobar_spec.rb')).to eq <<~EOF
          # frozen_string_literal: true

          require 'spec_helper'

          RSpec.describe 'Convert Foo to Bar' do
            let(:rewriter_name) { 'ruby/foobar' }
            let(:fake_file_path) { 'foobar.rb' }
            let(:test_content) { 'Foo' }
            let(:test_rewritten_content) { 'Bar' }

            include_examples 'convertable'
          end
        EOF
        FileUtils.rm_rf('lib/ruby')
        FileUtils.rm_rf('spec/ruby')
      end
    end
  end
end
