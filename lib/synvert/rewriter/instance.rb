# encoding: utf-8

module Synvert
  class Rewriter::Instance
    attr_accessor :current_node, :current_source, :current_file

    def initialize(file_pattern, &block)
      @actions = []
      @file_pattern = file_pattern
      @block = block
    end

    def process
      parser = Parser::CurrentRuby.new
      file_pattern = File.join(Configuration.instance.get(:path), @file_pattern)
      Dir.glob(file_pattern).each do |file_path|
        source = File.read(file_path)
        buffer = Parser::Source::Buffer.new file_path
        buffer.source = source

        parser.reset
        ast = parser.parse buffer

        @current_file = file_path
        @current_source = source
        @current_node = ast
        instance_eval &@block
        @current_node = ast

        @actions.sort.reverse.each do |action|
          source[action.begin_pos...action.end_pos] = action.rewritten_code
          source = remove_code_or_whole_line(source, action.line)
        end
        @actions = []

        File.write file_path, source
      end
    end

    def node
      @current_node
    end

    def within_node(options, &block)
      Rewriter::Scope.new(self, options, &block).process
    end

    alias with_node within_node

    def unless_exist_node(options, &block)
      Rewriter::UnlessExistCondition.new(self, options, &block).process
    end

    def if_only_exist_node(options, &block)
      Rewriter::IfOnlyExistCondition.new(self, options, &block).process
    end

    def append(code)
      @actions << Rewriter::AppendAction.new(self, code)
    end

    def insert(code)
      @actions << Rewriter::InsertAction.new(self, code)
    end

    def insert_after(node)
      @actions << Rewriter::InsertAfterAction.new(self, node)
    end

    def replace_with(code)
      @actions << Rewriter::ReplaceWithAction.new(self, code)
    end

    def remove
      @actions << Rewriter::RemoveAction.new(self)
    end

  private

    def remove_code_or_whole_line(source, line)
      newline_at_end_of_line = source[-1] == "\n"
      source_arr = source.split("\n")
      if source_arr[line - 1] && source_arr[line - 1].strip.empty?
        source_arr.delete_at(line - 1)
        source_arr.join("\n") + (newline_at_end_of_line ? "\n" : '')
      else
        source
      end
    end
  end
end
