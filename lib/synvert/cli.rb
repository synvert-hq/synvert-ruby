# frozen_string_literal: true

require 'optparse'
require 'fileutils'

module Synvert
  # Synvert command line interface.
  class CLI
    # Initialize the cli and run.
    #
    # @param args [Array] arguments, default is ARGV.
    # @return [Boolean] true if command runs successfully.
    def self.run(args = ARGV)
      new.run(args)
    end

    # Initialize a CLI.
    def initialize
      @options = { command: 'run', format: 'plain' }
    end

    # Run the CLI.
    # @param args [Array] arguments.
    # @return [Boolean] true if command runs successfully.
    def run(args)
      run_option_parser(args)

      case @options[:command]
      when 'list'
        read_rewriters
        list_available_rewriters
      when 'open'
        open_rewriter
      when 'query'
        read_rewriters
        query_available_rewriters
      when 'show'
        show_rewriter
      when 'sync'
        sync_snippets
      when 'generate'
        generate_snippet
      when 'execute'
        execute_snippet(@options[:execute_command])
      when 'test'
        rewriter = Synvert::Core::Utils.eval_snippet(@options[:snippet_name])
        test_snippet(rewriter)
      when 'run'
        rewriter = Synvert::Core::Utils.eval_snippet(@options[:snippet_name])
        run_snippet(rewriter)
      else
        # nothing to do
      end
      true
    rescue SystemExit
      true
    rescue Parser::SyntaxError => e
      puts "Syntax error: #{e.message}"
      puts "file #{e.diagnostic.location.source_buffer.name}"
      puts "line #{e.diagnostic.location.line}"
      false
    rescue StandardError
      false
    end

    private

    # Run OptionParser to parse arguments.
    def run_option_parser(args)
      optparse =
        OptionParser.new do |opts|
          opts.banner = 'Usage: synvert-ruby [project_path]'
          opts.on '-l', '--list', 'list all available snippets' do
            @options[:command] = 'list'
          end
          opts.on '-q', '--query QUERY', 'query specified snippets' do |query|
            @options[:command] = 'query'
            @options[:query] = query
          end
          opts.on '-s',
                  '--show SNIPPET_NAME',
                  'show specified snippet description, SNIPPET_NAME is combined by group and name, e.g. ruby/new_hash_syntax' do |snippet_name|
            @options[:command] = 'show'
            @options[:snippet_name] = snippet_name
          end
          opts.on '-o', '--open SNIPPET_NAME', 'Open a snippet' do |snippet_name|
            @options[:command] = 'open'
            @options[:snippet_name] = snippet_name
          end
          opts.on '-g', '--generate NEW_SNIPPET_NAME', 'generate a new snippet' do |name|
            @options[:command] = 'generate'
            @options[:snippet_name] = name
          end
          opts.on '--sync', 'sync snippets' do
            @options[:command] = 'sync'
          end
          opts.on '--execute EXECUTE_COMMAND', 'execute snippet' do |execute_command|
            @options[:command] = 'execute'
            @options[:execute_command] = execute_command
          end
          opts.on '-r',
                  '--run SNIPPET_NAME',
                  'run a snippet with snippet name, e.g. ruby/new_hash_syntax, or remote url, or local file path' do |snippet_name|
            @options[:command] = 'run'
            @options[:snippet_name] = snippet_name
          end
          opts.on '-t',
                  '--test SNIPPET_NAME',
                  'test a snippet with snippet name, e.g. ruby/new_hash_syntax, or remote url, or local file path' do |snippet_name|
            @options[:command] = 'test'
            @options[:snippet_name] = snippet_name
          end
          opts.on '--show-run-process', 'show processing files when running a snippet' do
            Core::Configuration.show_run_process = true
          end
          opts.on '--only-paths DIRECTORIES',
                  'only specified files or directories, separated by comma, e.g. app/models,app/controllers' do |directories|
            @options[:only_paths] = directories
          end
          opts.on '--skip-paths FILE_PATTERNS',
                  'skip specified files or directories, separated by comma, e.g. vendor/,lib/**/*.rb' do |file_patterns|
            @options[:skip_paths] = file_patterns
          end
          opts.on '-f', '--format FORMAT', 'output format' do |format|
            @options[:format] = format
          end
          opts.on '--number-of-workers NUMBER_OF_WORKERS',
                  'set the number of workers, if it is greater than 1, it tests snippet in parallel' do |number_of_workers|
            Core::Configuration.number_of_workers = number_of_workers.to_i
          end
          opts.on '--double-quote', 'prefer double quote, it uses single quote by default' do |double_quote|
            Core::Configuration.single_quote = false
          end
          opts.on '--tab-width TAB_WIDTH', 'prefer tab width, it uses 2 by default' do |tab_width|
            Core::Configuration.tab_width = tab_width.to_i
          end
          opts.on '-v', '--version', 'show this version' do
            puts "#{VERSION} (with synvert-core #{Core::VERSION} and parser #{Parser::VERSION})"
            exit
          end
        end
      paths = optparse.parse(args)
      Core::Configuration.root_path = paths.first || Dir.pwd
      if @options[:only_paths] && !@options[:only_paths].empty?
        Core::Configuration.only_paths = @options[:only_paths].split(",").map { |only_path| only_path.strip }
      end
      if @options[:skip_paths] && !@options[:skip_paths].empty?
        Core::Configuration.skip_paths = @options[:skip_paths].split(",").map { |skip_path| skip_path.strip }
      end
    end

    # read all rewriters.
    def read_rewriters
      Dir.glob(File.join(default_snippets_home, 'lib/**/*.rb')).each { |file| require file }
    end

    # List and print all available rewriters.
    def list_available_rewriters
      if Core::Rewriter.availables.empty?
        puts "There is no snippet under #{default_snippets_home}, please run `synvert-ruby --sync` to fetch snippets."
        return
      end

      if plain_output?
        Core::Rewriter.availables.each do |group, rewriters|
          puts group
          rewriters.each do |name, _rewriter|
            puts '    ' + name
          end
        end
        puts
      elsif json_output?
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

        puts output.to_json
      end
    end

    # Open one rewriter.
    def open_rewriter
      editor = [ENV['SYNVERT_EDITOR'], ENV['EDITOR']].find { |e| !e.nil? && !e.empty? }
      return puts 'To open a synvert snippet, set $EDITOR or $SYNVERT_EDITOR' unless editor

      path = File.expand_path(File.join(default_snippets_home, "lib/#{@options[:snippet_name]}.rb"))
      if File.exist?(path)
        system editor, path
      else
        puts "Can't run #{editor} #{path}"
      end
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
    def show_rewriter
      path = File.expand_path(File.join(default_snippets_home, "lib/#{@options[:snippet_name]}.rb"))
      if File.exist?(path)
        puts File.read(path)
      else
        puts "snippet #{@options[:snippet_name]} not found"
      end
    end

    # sync snippets
    def sync_snippets
      Snippet.new(default_snippets_home).sync
      puts 'synvert snippets are synced'
    end

    # eval snippet name by user input
    def eval_snippet_name_by_input(input)
      eval(input)
    end

    # run a snippet
    def run_snippet(rewriter)
      if plain_output?
        puts "===== #{rewriter.group}/#{rewriter.name} started ====="
        rewriter.process
        rewriter.warnings.each do |warning|
          puts '[Warn] ' + warning.message
        end
        puts "===== #{rewriter.group}/#{rewriter.name} done ====="
      elsif json_output?
        rewriter.process
        output = {
          affected_files: rewriter.affected_files.union(rewriter.sub_snippets.sum(Set.new, &:affected_files)).to_a,
          warnings: rewriter.warnings.union(rewriter.sub_snippets.sum([], &:warnings))
        }
        puts output.to_json
      end
    rescue StandardError => e
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
      puts({ error: e.message }.to_json)
      raise
    end

    # execute snippet
    def execute_snippet(execute_command)
      rewriter = eval_snippet_name_by_input(STDIN.read)
      if execute_command == 'test'
        test_snippet(rewriter)
      else
        run_snippet(rewriter)
      end
    end

    # generate a new snippet
    def generate_snippet
      group, name = @options[:snippet_name].split('/')
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

    def default_snippets_home
      # ENV['HOME'] may use \ as file separator,
      # but File.join always uses / as file separator.
      ENV['SYNVERT_SNIPPETS_HOME'] || File.join(ENV['HOME'].gsub("\\", "/"), '.synvert-ruby')
    end

    def plain_output?
      @options[:format] == 'plain'
    end

    def json_output?
      @options[:format] == 'json'
    end
  end
end
