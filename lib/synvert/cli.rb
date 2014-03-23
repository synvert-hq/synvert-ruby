# coding: utf-8
require 'optparse'
require 'find'
require 'open-uri'

module Synvert
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      Configuration.instance.set 'snippet_paths', []
      Configuration.instance.set 'snippet_names', []

      command = :run
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: synvert [project_path]"
        opts.on '--load-snippets SNIPPET_PATHS', 'load additional snippets, snippet paths can be local file path or remote http url' do |snippet_paths|
          Configuration.instance.set 'snippet_paths', snippet_paths.split(',')
        end
        opts.on '--list-snippets', 'list all available snippets' do
          command = :list
        end
        opts.on '--run-snippets SNIPPET_NAMES', 'run specified snippets' do |snippet_names|
          Configuration.instance.set 'snippet_names', snippet_names.split(',')
        end
      end
      paths = optparse.parse(args)
      Configuration.instance.set :path, paths.first || Dir.pwd

      Dir.glob(File.join(File.dirname(__FILE__), 'snippets/**/*.rb')).each { |file| eval(File.read(file)) }
      Configuration.instance.get('snippet_paths').each do |snippet_path|
        if snippet_path =~ /^http/
          uri = URI.parse snippet_path
          eval(uri.read)
        else
          eval(File.read(snippet_path))
        end
      end
      Configuration.instance.get('snippet_names').each do |snippet_name|
        rewriter = Rewriter.call snippet_name
        puts "-------#{snippet_name} todo-------"
        puts rewriter.todo_list
      end

      if :list == command
        puts "%-40s %s" % ['name', 'description']
        puts "%-40s %s" % ['----', '-----------']
        Rewriter.availables.each do |rewriter|
          puts "%-40s %s" % [rewriter.name, rewriter.description]
        end
      end
    end
  end
end
