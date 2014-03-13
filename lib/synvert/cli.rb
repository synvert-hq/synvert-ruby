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

      %w(factory_girl/syntax_methods.rb rails/upgrade_3_2_to_4_0.rb).each do |path|
        eval(File.read(File.join(File.dirname(__FILE__), path))).process
      end
    end
  end
end
