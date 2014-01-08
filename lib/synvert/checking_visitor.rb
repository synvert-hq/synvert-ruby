# coding: utf-8
module Synvert
  class CheckingVisitor
    attr_reader :converters

    def initialize(options={})
      @converters = options[:converters] || [
        Synvert::FactoryGirl::SyntaxMethodsConverter.new
      ]
    end

    def convert_file(filename)
      source = File.read filename
      converted_source = convert(filename, source)
      if source != converted_source
        File.write(filename, converted_source)
      end
    end

    def convert(filename, source)
      source_buffer = Parser::Source::Buffer.new filename
      source_buffer.source = source

      parser = Parser::CurrentRuby.new
      ast = parser.parse source_buffer

      converted_source = source
      @converters.each do |converter|
        if Array(converter.interesting_files).any? { |file_pattern| filename =~ file_pattern }
          converted_source = converter.rewrite(source_buffer, ast)
        end
      end

      converted_source
    end
  end
end
