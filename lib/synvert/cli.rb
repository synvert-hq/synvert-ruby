# coding: utf-8
require 'optparse'
require 'open-uri'

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
      @options = {command: 'run', snippet_paths: [], snippet_names: []}
      Configuration.instance.set :skip_files, []
    end

    # Run the CLI.
    # @param args [Array] arguments.
    # @return [Boolean] true if command runs successfully.
    def run(args)
      run_option_parser(args)
      load_rewriters

      case @options[:command]
      when 'list' then list_available_rewriters
      when 'query' then query_available_rewriters
      when 'show' then show_rewriter
      else
        @options[:snippet_names].each do |snippet_name|
          puts "===== #{snippet_name} started ====="
          rewriter = Rewriter.call snippet_name
          puts rewriter.todo if rewriter.todo
          puts "===== #{snippet_name} done ====="
        end
      end
      true
    rescue SystemExit
      true
    rescue Parser::SyntaxError => e
      puts "Syntax error: #{e.message}"
      puts "file #{e.diagnostic.location.source_buffer.name}"
      puts "line #{e.diagnostic.location.line}"
      false
    rescue Exception => e
      print "Error: "
      p e
      false
    end

  private

    # Run OptionParser to parse arguments.
    def run_option_parser(args)
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: synvert [project_path]"
        opts.on '-d', '--load SNIPPET_PATHS', 'load additional snippets, snippet paths can be local file path or remote http url' do |snippet_paths|
          @options[:snippet_paths] = snippet_paths.split(',').map(&:strip)
        end
        opts.on '-l', '--list', 'list all available snippets' do
          @options[:command] = 'list'
        end
        opts.on '-q', '--query QUERY', 'query specified snippets' do |query|
          @options[:command] = 'query'
          @options[:query] = query
        end
        opts.on '--skip FILE_PATTERNS', 'skip specified files or directories, separated by comma, e.g. app/models/post.rb,vendor/plugins/**/*.rb' do |file_patterns|
          @options[:skip_file_patterns] = file_patterns.split(',')
        end
        opts.on '-s', '--show SNIPPET_NAME', 'show specified snippet description' do |snippet_name|
          @options[:command] = 'show'
          @options[:snippet_name] = snippet_name
        end
        opts.on '-r', '--run SNIPPET_NAMES', 'run specified snippets' do |snippet_names|
          @options[:snippet_names] = snippet_names.split(',').map(&:strip)
        end
        opts.on '-v', '--version', 'show this version' do
          puts Synvert::VERSION
          exit
        end
      end
      paths = optparse.parse(args)
      Configuration.instance.set :path, paths.first || Dir.pwd
      if @options[:skip_file_patterns] && !@options[:skip_file_patterns].empty?
        skip_files = @options[:skip_file_patterns].map { |file_pattern|
          full_file_pattern = File.join(Configuration.instance.get(:path), file_pattern)
          Dir.glob(full_file_pattern)
        }.flatten
        Configuration.instance.set :skip_files, skip_files
      end
    end

    # Load all rewriters.
    def load_rewriters
      Dir.glob(File.join(File.dirname(__FILE__), 'snippets/**/*.rb')).each { |file| eval(File.read(file)) }

      @options[:snippet_paths].each do |snippet_path|
        if snippet_path =~ /^http/
          uri = URI.parse snippet_path
          eval(uri.read)
        else
          eval(File.read(snippet_path))
        end
      end
    end

    # List and print all available rewriters.
    def list_available_rewriters
      Rewriter.availables.each do |rewriter|
        print rewriter.name.to_s + "  "
      end
      puts
    end

    # Query and print available rewriters.
    def query_available_rewriters
      Rewriter.availables.each do |rewriter|
        if rewriter.name.include? @options[:query]
          print rewriter.name + "  "
        end
      end
      puts
    end

    # Show and print one rewriter.
    def show_rewriter
      rewriter = Rewriter.fetch(@options[:snippet_name])
      if rewriter
        rewriter.process_with_sandbox
        puts rewriter.description
        rewriter.sub_snippets.each do |sub_rewriter|
          puts
          puts "=" * 80
          puts "snippet: #{sub_rewriter.name}"
          puts "=" * 80
          puts sub_rewriter.description
        end
      else
        puts "snippet #{@options[:snippet_name]} not found"
      end
    end
  end
end
