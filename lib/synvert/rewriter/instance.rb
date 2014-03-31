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
        begin
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

          @actions.sort!
          check_conflict_actions
          @actions.reverse.each do |action|
            source[action.begin_pos...action.end_pos] = action.rewritten_code
            source = remove_code_or_whole_line(source, action.line)
          end
          @actions = []

          File.write file_path, source
        end while !@conflict_actions.empty?
      end
    end

    def node
      @current_node
    end

    def within_node(rules, &block)
      Rewriter::Scope.new(self, rules, &block).process
    end

    alias with_node within_node

    def if_exist_node(rules, &block)
      Rewriter::IfExistCondition.new(self, rules, &block).process
    end

    def unless_exist_node(rules, &block)
      Rewriter::UnlessExistCondition.new(self, rules, &block).process
    end

    def if_only_exist_node(rules, &block)
      Rewriter::IfOnlyExistCondition.new(self, rules, &block).process
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

    def check_conflict_actions
      i = @actions.length - 1
      @conflict_actions = []
      while i > 0
        if @actions[i].begin_pos <= @actions[i - 1].end_pos
          @conflict_actions << @actions.delete_at(i)
        end
        i -= 1
      end
      @conflict_actions
    end

    def remove_code_or_whole_line(source, line)
      newline_at_end_of_line = source[-1] == "\n"
      source_arr = source.split("\n")
      if source_arr[line - 1] && source_arr[line - 1].strip.empty?
        source_arr.delete_at(line - 1)
        if source_arr[line - 2] && source_arr[line - 2].strip.empty? && source_arr[line - 1] && source_arr[line - 1].strip.empty?
          source_arr.delete_at(line - 1)
        end
        source_arr.join("\n") + (newline_at_end_of_line ? "\n" : '')
      else
        source
      end
    end
  end
end
