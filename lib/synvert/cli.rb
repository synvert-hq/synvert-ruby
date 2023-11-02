# frozen_string_literal: true

require 'optparse'
require 'fileutils'
require 'parser'

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
        Command.read_rewriters
        Command.list_available_rewriters(@options[:foramt])
      when 'open'
        Command.open_rewriter(@options[:snippet_name])
      when 'query'
        Command.read_rewriters
        Command.query_available_rewriters
      when 'show'
        Command.show_rewriter(@options[:snippet_name])
      when 'sync'
        Command.sync_snippets
      when 'generate'
        Command.generate_snippet(@options[:snippet_name])
      when 'execute'
        Command.read_helpers
        rewriter = eval_snippet_name_by_input(STDIN.read)
        if @options[:execute_command] == 'test'
          Command.test_snippet(rewriter)
        else
          Command.run_snippet(rewriter, @options[:format])
        end
      when 'test'
        Command.read_helpers
        rewriter = Synvert::Core::Utils.eval_snippet(@options[:snippet_name])
        Command.test_snippet(rewriter)
      when 'run'
        Command.read_helpers
        rewriter = Synvert::Core::Utils.eval_snippet(@options[:snippet_name])
        Command.run_snippet(rewriter, @options[:format])
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
          opts.on '--double-quote', 'prefer double quote, it uses single quote by default' do |_double_quote|
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

    # eval snippet name by user input
    def eval_snippet_name_by_input(input)
      eval(input)
    end
  end
end
