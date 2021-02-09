require 'optparse'

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
      @options = {command: 'run', custom_snippet_paths: [], snippet_names: []}
    end

    # Run the CLI.
    # @param args [Array] arguments.
    # @return [Boolean] true if command runs successfully.
    def run(args)
      run_option_parser(args)

      case @options[:command]
      when 'list'
        load_rewriters
        list_available_rewriters
      when 'open'
        open_rewriter
      when 'query'
        load_rewriters
        query_available_rewriters
      when 'show'
        load_rewriters
        show_rewriter
      when 'sync'
        sync_snippets
      else # run
        load_rewriters
        @options[:snippet_names].each do |snippet_name|
          puts "===== #{snippet_name} started ====="
          group, name = snippet_name.split('/')
          rewriter = Core::Rewriter.call group, name
          rewriter.warnings.each do |warning|
            puts '[Warn] ' + warning.message
          end
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
    rescue Synvert::Core::RewriterNotFound => e
      puts e.message
      false
    end

    private

    # Run OptionParser to parse arguments.
    def run_option_parser(args)
      optparse = OptionParser.new do |opts|
        opts.banner = 'Usage: synvert [project_path]'
        opts.on '-d', '--load SNIPPET_PATHS', 'load custom snippets, snippet paths can be local file path or remote http url' do |snippet_paths|
          @options[:custom_snippet_paths] = snippet_paths.split(',').map(&:strip)
        end
        opts.on '-l', '--list', 'list all available snippets' do
          @options[:command] = 'list'
        end
        opts.on '-o', '--open SNIPPET_NAME', 'Open a snippet' do |snippet_name|
          @options[:command] = 'open'
          @options[:snippet_name] = snippet_name
        end
        opts.on '-q', '--query QUERY', 'query specified snippets' do |query|
          @options[:command] = 'query'
          @options[:query] = query
        end
        opts.on '--skip FILE_PATTERNS', 'skip specified files or directories, separated by comma, e.g. app/models/post.rb,vendor/plugins/**/*.rb' do |file_patterns|
          @options[:skip_file_patterns] = file_patterns.split(',')
        end
        opts.on '-s', '--show SNIPPET_NAME', 'show specified snippet description, SNIPPET_NAME is combined by group and name, e.g. ruby/new_hash_syntax' do |snippet_name|
          @options[:command] = 'show'
          @options[:snippet_name] = snippet_name
        end
        opts.on '--sync', 'sync snippets' do
          @options[:command] = 'sync'
        end
        opts.on '-r', '--run SNIPPET_NAMES', 'run specified snippets, each SNIPPET_NAME is combined by group and name, e.g. ruby/new_hash_syntax,ruby/new_lambda_syntax' do |snippet_names|
          @options[:snippet_names] = snippet_names.split(',').map(&:strip)
        end
        opts.on '-v', '--version', 'show this version' do
          puts Core::VERSION
          exit
        end
      end
      paths = optparse.parse(args)
      Core::Configuration.path = paths.first || Dir.pwd
      if @options[:skip_file_patterns] && !@options[:skip_file_patterns].empty?
        skip_files = @options[:skip_file_patterns].map do |file_pattern|
          full_file_pattern = File.join(Core::Configuration.path, file_pattern)
          Dir.glob(full_file_pattern)
        end.flatten
        Core::Configuration.skip_files = skip_files
      end
    end

    # Load all rewriters.
    def load_rewriters
      Dir.glob(File.join(default_snippets_path, 'lib/**/*.rb')).each { |file| require file }

      @options[:custom_snippet_paths].each do |snippet_path|
        if snippet_path =~ /^http/
          uri = URI.parse snippet_path
          eval(uri.read)
        else
          require snippet_path
        end
      end
    rescue
      FileUtils.rm_rf default_snippets_path
      retry
    end

    # List and print all available rewriters.
    def list_available_rewriters
      if Core::Rewriter.availables.empty?
        puts 'There is no snippet under ~/.synvert, please run `synvert --sync` to fetch snippets.'
      else
        Core::Rewriter.availables.each do |group, rewriters|
          puts group
          rewriters.each do |name, rewriter|
            puts '    ' + name
          end
        end
        puts
      end
    end

    # Open one rewriter.
    def open_rewriter
      editor = [ENV['SYNVERT_EDITOR'], ENV['EDITOR']].find { |e| !e.nil? && !e.empty? }
      return puts 'To open a synvert snippet, set $EDITOR or $SYNVERT_EDITOR' unless editor

      path = File.expand_path(File.join(default_snippets_path, "lib/#{@options[:snippet_name]}.rb"))
      if File.exist? path
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
          rewriters.each do |name, rewriter|
            puts '    ' + name
          end
        elsif rewriters.keys.any? { |name| name.include? @options[:query] }
          puts group
          rewriters.each do |name, rewriter|
            puts '    ' + name if name.include?(@options[:query])
          end
        end
      end
      puts
    end

    # Show and print one rewriter.
    def show_rewriter
      group, name = @options[:snippet_name].split('/')
      rewriter = Core::Rewriter.fetch(group, name)
      if rewriter
        rewriter.process_with_sandbox
        puts rewriter.description
        rewriter.sub_snippets.each do |sub_rewriter|
          puts
          puts '=' * 80
          puts "snippet: #{sub_rewriter.name}"
          puts '=' * 80
          puts sub_rewriter.description
        end
      else
        puts "snippet #{@options[:snippet_name]} not found"
      end
    end

    # sync snippets
    def sync_snippets
      Snippet.new(default_snippets_path).sync
      puts 'synvert snippets are synced'
      core_version = Snippet.fetch_core_version
      if Gem::Version.new(core_version) > Gem::Version.new(Synvert::Core::VERSION)
        puts "synvert-core is updated, please install synvert-core #{core_version}"
      end
    end

    def default_snippets_path
      File.join(ENV['HOME'], '.synvert')
    end
  end
end
