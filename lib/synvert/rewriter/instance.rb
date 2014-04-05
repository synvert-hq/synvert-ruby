# encoding: utf-8

module Synvert
  # Instance is an execution unit, it finds specified ast nodes,
  # checks if the nodes match some conditions, then add, replace or remove code.
  #
  # One instance can contains one or many [Synvert::Rewriter::Scope] and [Synvert::Rewriter::Condition].
  class Rewriter::Instance
    # @!attribute [rw] current_node
    #   @return current parsing node
    # @!attribute [rw] current_source
    #   @return current source code of file
    # @!attribute [rw] current_file
    #   @return current filename
    attr_accessor :current_node, :current_source, :current_file

    # Initialize an instance.
    #
    # @param file_pattern [String] pattern to find files, e.g. spec/**/*_spec.rb
    # @param block [Block] block code to find nodes, match conditions and rewrite code.
    # @return [Synvert::Rewriter::Instance]
    def initialize(file_pattern, &block)
      @actions = []
      @file_pattern = file_pattern
      @block = block
    end

    # Process the instance.
    # It finds all files, for each file, it executes the block code, gets all rewrite actions,
    # and rewrite source code back to original file.
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

    # Gets current node, it allows to get current node in block code.
    #
    # @return [Parser::AST::Node]
    def node
      @current_node
    end

    #######
    # DSL #
    #######

    # Parse within_node dsl, it creates a [Synvert::Rewriter::Scope] to find matching ast nodes,
    # then continue operating on each matching ast node.
    #
    # @param rules [Hash] rules to find mathing ast nodes.
    # @param block [Block] block code to continue operating on the matching nodes.
    def within_node(rules, &block)
      Rewriter::Scope.new(self, rules, &block).process
    end

    alias with_node within_node

    # Parse if_exist_node dsl, it creates a [Synvert::Rewriter::IfExistCondition] to check
    # if matching nodes exist in the child nodes, if so, then continue operating on each matching ast node.
    #
    # @param rules [Hash] rules to check mathing ast nodes.
    # @param block [Block] block code to continue operating on the matching nodes.
    def if_exist_node(rules, &block)
      Rewriter::IfExistCondition.new(self, rules, &block).process
    end

    # Parse unless_exist_node dsl, it creates a [Synvert::Rewriter::UnlessExistCondition] to check
    # if matching nodes doesn't exist in the child nodes, if so, then continue operating on each matching ast node.
    #
    # @param rules [Hash] rules to check mathing ast nodes.
    # @param block [Block] block code to continue operating on the matching nodes.
    def unless_exist_node(rules, &block)
      Rewriter::UnlessExistCondition.new(self, rules, &block).process
    end

    # Parse if_only_exist_node dsl, it creates a [Synvert::Rewriter::IfOnlyExistCondition] to check
    # if current node has only one child node and the child node matches rules,
    # if so, then continue operating on each matching ast node.
    #
    # @param rules [Hash] rules to check mathing ast nodes.
    # @param block [Block] block code to continue operating on the matching nodes.
    def if_only_exist_node(rules, &block)
      Rewriter::IfOnlyExistCondition.new(self, rules, &block).process
    end

    # Parse append dsl, it creates a [Synvert::Rewriter::AppendAction] to
    # append the code to the bottom of current node body.
    #
    # @param code [String] code need to be appended.
    def append(code)
      @actions << Rewriter::AppendAction.new(self, code)
    end

    # Parse insert dsl, it creates a [Synvert::Rewriter::InsertAction] to
    # insert the code to the top of current node body.
    #
    # @param code [String] code need to be inserted.
    def insert(code)
      @actions << Rewriter::InsertAction.new(self, code)
    end

    # Parse insert_after dsl, it creates a [Synvert::Rewriter::InsertAfterAction] to
    # insert the code next to the current node.
    #
    # @param code [String] code need to be inserted.
    def insert_after(node)
      @actions << Rewriter::InsertAfterAction.new(self, node)
    end

    # Parse replace_with dsl, it creates a [Synvert::Rewriter::ReplaceWithAction] to
    # replace current node with code.
    #
    # @param code [String] code need to be replaced with.
    def replace_with(code)
      @actions << Rewriter::ReplaceWithAction.new(self, code)
    end

    # Parse remove dsl, it creates a [Synvert::Rewriter::RemoveAction] to current node.
    def remove
      @actions << Rewriter::RemoveAction.new(self)
    end

  private

    # It changes source code from bottom to top, and it can change source code twice at the same time.
    # So if there is an overlap between two actions, it removes the conflict actions and operate them in the next loop.
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

    # It checks if code is removed and that line is empty.
    #
    # @param source [String] source code of file
    # @param line [String] the line number
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
