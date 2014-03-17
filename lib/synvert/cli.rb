# coding: utf-8
require 'optparse'
require 'find'

module Synvert
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: synvert path"
      end
      paths = optparse.parse(args)
      Configuration.instance.set :path, paths.first || Dir.pwd

      rewriters = Dir.glob(File.join(File.dirname(__FILE__), 'snippets/**/*.rb')).map do |file|
        eval(File.read(file))
      end
      rewriters.map(&:process)
    end
  end
end
