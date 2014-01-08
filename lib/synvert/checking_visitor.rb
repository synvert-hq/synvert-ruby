# coding: utf-8
require 'parser'
require 'parser/current'

module Synvert
  class CheckingVisitor
    def initialize(options={})
      @converters = options[:converters] || [
        Synvert::FactoryGirl::SyntaxMethodsConverter.new
      ]
    end

    def convert(filename, content)
      source_buffer = Parser::Source::Buffer.new filename
      source_buffer.source = content

      parser = Parser::CurrentRuby.new
      ast = parser.parse source_buffer

      converted_source = content
      @converters.each do |converter|
        if Array(converter.interesting_files).any? { |file_pattern| filename =~ file_pattern }
          converted_source = converter.rewrite(source_buffer, ast)
        end
      end

      converted_source
    end
  end
end
