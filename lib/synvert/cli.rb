# coding: utf-8
require 'optparse'
require 'find'

module Synvert
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      Configuration.instance.set 'snippets', []

      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: synvert [project_path]"
        opts.on '--snippets SNIPPETS', 'run specified snippets' do |snippets|
          Configuration.instance.set 'snippets', snippets.split(',')
        end
      end
      paths = optparse.parse(args)
      Configuration.instance.set :path, paths.first || Dir.pwd

      Dir.glob(File.join(File.dirname(__FILE__), 'snippets/**/*.rb')).each { |file| eval(File.read(file)) }
      Configuration.instance.get('snippets').each { |snippet| Rewriter.call snippet }
    end
  end
end
