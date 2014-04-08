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
      Configuration.instance.set 'snippet_paths', []
      Configuration.instance.set 'snippet_names', []

      @command = :run
    end

    # Run the CLI.
    # @param args [Array] arguments.
    # @return [Boolean] true if command runs successfully.
    def run(args)
      run_option_parser(args)
      load_rewriters

      if :list == @command
        list_available_rewriters
      else
        Configuration.instance.get('snippet_names').each do |snippet_name|
          puts "===== #{snippet_name} started ====="
          rewriter = Rewriter.call snippet_name
          puts rewriter.todo if rewriter.todo
          puts "===== #{snippet_name} done ====="
        end
      end
      true
    rescue Exception => e
      puts "Error: " + e.message
      false
    end

  private

    # Run OptionParser to parse arguments.
    def run_option_parser(args)
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: synvert [project_path]"
        opts.on '-d', '--load SNIPPET_PATHS', 'load additional snippets, snippet paths can be local file path or remote http url' do |snippet_paths|
          Configuration.instance.set 'snippet_paths', snippet_paths.split(',')
        end
        opts.on '-l', '--list', 'list all available snippets' do
          @command = :list
        end
        opts.on '-r', '--run SNIPPET_NAMES', 'run specified snippets' do |snippet_names|
          Configuration.instance.set 'snippet_names', snippet_names.split(',')
        end
      end
      paths = optparse.parse(args)
      Configuration.instance.set :path, paths.first || Dir.pwd
    end

    # Load all rewriters.
    def load_rewriters
      Dir.glob(File.join(File.dirname(__FILE__), 'snippets/**/*.rb')).each { |file| eval(File.read(file)) }

      Configuration.instance.get('snippet_paths').each do |snippet_path|
        if snippet_path =~ /^http/
          uri = URI.parse snippet_path
          eval(uri.read)
        else
          eval(File.read(snippet_path))
        end
      end
    end

    # Print all available rewriters.
    def list_available_rewriters
      Rewriter.availables.each do |rewriter|
        puts rewriter.name
      end
    end
  end
end
