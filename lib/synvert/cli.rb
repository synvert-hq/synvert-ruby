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

      load(File.join(File.dirname(__FILE__), 'factory_girl/syntax_methods.rb'))

      ObjectSpace.each_object Synvert::Rewriter do |rewriter|
        rewriter.process
      end
    end
  end
end
