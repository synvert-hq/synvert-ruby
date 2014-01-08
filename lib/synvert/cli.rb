# coding: utf-8
require 'find'

module Synvert
  class CLI
    def self.run
      new.run
    end

    def initialize
      @checking_visitor = CheckingVisitor.new
    end

    def run
      Find.find(".") do |path|
        if FileTest.directory?(path)
          next
        else
          @checking_visitor.convert_file(path) if path =~ /\.rb$/
        end
      end
    end
  end
end
