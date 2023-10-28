# frozen_stirng_literal: true

module Synvert
  class Command
    class << self
      # sync snippets
      def sync_snippets
        if File.exist?(default_snippets_home)
          Dir.chdir(default_snippets_home) do
            Kernel.system('git checkout . && git pull --rebase')
          end
        else
          Kernel.system("git clone https://github.com/xinminlabs/synvert-snippets-ruby.git #{default_snippets_home}")
        end
        puts 'synvert snippets are synced'
      end

      # read all rewriters.
      def read_rewriters
        Dir.glob(File.join(default_snippets_home, 'lib/**/*.rb')).each { |file| require file }
      end

      # read all helpers.
      def read_helpers
        Dir.glob(File.join(default_snippets_home, 'lib/helpers/**/*.rb')).each { |file| require file }
      end

      # Open one rewriter.
      def open_rewriter(snippet_name)
        editor = [ENV['SYNVERT_EDITOR'], ENV['EDITOR']].find { |e| !e.nil? && !e.empty? }
        return puts 'To open a synvert snippet, set $EDITOR or $SYNVERT_EDITOR' unless editor

        path = File.expand_path(File.join(default_snippets_home, "lib/#{snippet_name}.rb"))
        if File.exist?(path)
          system editor, path
        else
          puts "Can't run #{editor} #{path}"
        end
      end

      # List and print all available rewriters.
      def list_available_rewriters(format)
        if Core::Rewriter.availables.empty?
          puts "There is no snippet under #{default_snippets_home}, please run `synvert-ruby --sync` to fetch snippets."
          return
        end

        if format == 'json'
          puts available_rewriters.to_json
        else
          Core::Rewriter.availables.each do |group, rewriters|
            puts group
            rewriters.each do |name, _rewriter|
              puts '    ' + name
            end
          end
          puts
        end
      end

      def available_rewriters
        output = []
        Core::Rewriter.availables.each do |group, rewriters|
          rewriters.each do |name, rewriter|
            rewriter.process_with_sandbox
            sub_snippets =
              rewriter.sub_snippets.map { |sub_snippet|
                { group: sub_snippet.group, name: sub_snippet.name }
              }
            item = { group: group, name: name, description: rewriter.description, sub_snippets: sub_snippets }
            item[:ruby_version] = rewriter.ruby_version.version if rewriter.ruby_version
            item[:gem_spec] = { name: rewriter.gem_spec.name, version: rewriter.gem_spec.version } if rewriter.gem_spec
            output << item
          end
        end
        output
      end

      # Query and print available rewriters.
      def query_available_rewriters
        Core::Rewriter.availables.each do |group, rewriters|
          if group.include? @options[:query]
            puts group
            rewriters.each do |name, _rewriter|
              puts '    ' + name
            end
          elsif rewriters.keys.any? { |name| name.include? @options[:query] }
            puts group
            rewriters.each do |name, _rewriter|
              puts '    ' + name if name.include?(@options[:query])
            end
          end
        end
        puts
      end

      # Show and print one rewriter.
      def show_rewriter(snippet_name)
        path = File.expand_path(File.join(default_snippets_home, "lib/#{snippet_name}.rb"))
        if File.exist?(path)
          puts File.read(path)
        else
          puts "snippet #{snippet_name} not found"
        end
      end

      # generate a new snippet
      def generate_snippet(snippet_name)
        group, name = snippet_name.split('/')
        FileUtils.mkdir_p("lib/#{group}")
        FileUtils.mkdir_p("spec/#{group}")
        lib_content = <<~EOF
          # frozen_string_literal: true

          Synvert::Rewriter.new '#{group}', '#{name}' do
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
        spec_content = <<~EOF
          # frozen_string_literal: true

          require 'spec_helper'

          RSpec.describe 'Convert Foo to Bar' do
            let(:rewriter_name) { '#{group}/#{name}' }
            let(:fake_file_path) { 'foobar.rb' }
            let(:test_content) { 'Foo' }
            let(:test_rewritten_content) { 'Bar' }

            include_examples 'convertable'
          end
        EOF
        File.write("lib/#{group}/#{name}.rb", lib_content)
        File.write("spec/#{group}/#{name}_spec.rb", spec_content)
      end

      # run a snippet
      def run_snippet(rewriter, format)
        if format == 'json'
          rewriter.process
          output = {
            affected_files: rewriter.affected_files.union(rewriter.sub_snippets.sum(Set.new, &:affected_files)).to_a,
            warnings: rewriter.warnings.union(rewriter.sub_snippets.sum([], &:warnings))
          }
          puts output.to_json
        else
          puts "===== #{rewriter.group}/#{rewriter.name} started ====="
          rewriter.process
          rewriter.warnings.each do |warning|
            puts '[Warn] ' + warning.message
          end
          puts "===== #{rewriter.group}/#{rewriter.name} done ====="
        end
      rescue StandardError => e
        if ENV['DEBUG']
          puts e.backtrace.join("\n")
        end
        if plain_output?
          puts "Error: #{e.message}"
        else
          puts({ error: e.message }.to_json)
        end
        raise
      end

      # test a snippet
      def test_snippet(rewriter)
        results = rewriter.test
        puts results.to_json
      rescue StandardError => e
        if ENV['DEBUG']
          puts e.backtrace.join("\n")
        end
        puts({ error: e.message }.to_json)
        raise
      end

      def default_snippets_home
        # ENV['HOME'] may use \ as file separator,
        # but File.join always uses / as file separator.
        ENV['SYNVERT_SNIPPETS_HOME'] || File.join(ENV['HOME'].gsub("\\", "/"), '.synvert-ruby')
      end
    end
  end
end