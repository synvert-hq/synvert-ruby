# encoding: utf-8

module Synvert
  # Action defines rewriter action, add, replace or remove code.
  class Rewriter::Action
    # Initialize an action.
    #
    # @param instance [Synvert::Rewriter::Instance]
    # @param code {String] new code to add, replace or remove.
    def initialize(instance, code)
      @instance = instance
      @code = code
      @node = @instance.current_node
    end

    # Line number of the node.
    #
    # @return [Integer] line number.
    def line
      @node.loc.expression.line
    end

    # The rewritten source code with proper indent.
    #
    # @return [String] rewritten code.
    def rewritten_code
      if rewritten_source.split("\n").length > 1
        "\n\n" + rewritten_source.split("\n").map { |line|
          indent(@node) + line
        }.join("\n")
      else
        "\n" + indent(@node) + rewritten_source
      end
    end

    # The rewritten source code.
    #
    # @return [String] rewritten source code.
    def rewritten_source
      @rewritten_source ||= @node.rewritten_source(@code)
    end

    # Compare actions by begin position.
    #
    # @param action [Synvert::Rewriter::Action]
    # @return [Integer] -1, 0 or 1
    def <=>(action)
      self.begin_pos <=> action.begin_pos
    end
  end

  # ReplaceWithAction to replace code.
  class Rewriter::ReplaceWithAction < Rewriter::Action
    # Begin position of code to replace.
    #
    # @return [Integer] begin position.
    def begin_pos
      @node.loc.expression.begin_pos
    end

    # End position of code to replace.
    #
    # @return [Integer] end position.
    def end_pos
      @node.loc.expression.end_pos
    end

    # The rewritten source code with proper indent.
    #
    # @return [String] rewritten code.
    def rewritten_code
      if rewritten_source.split("\n").length > 1
        "\n\n" + rewritten_source.split("\n").map { |line|
          indent(@node) + line
        }.join("\n")
      else
        rewritten_source
      end
    end

  private

    # Indent of the node
    #
    # @param node [Parser::AST::Node]
    # @return [String] n times whitesphace
    def indent(node)
      ' ' * node.indent
    end
  end

  # AppendWithAction to append code to the bottom of node body.
  class Rewriter::AppendAction < Rewriter::Action
    # Begin position to append code.
    #
    # @return [Integer] begin position.
    def begin_pos
      if :begin == @node.type
        @node.loc.expression.end_pos
      else
        @node.loc.expression.end_pos - 4
      end
    end

    # End position, always same to begin position.
    #
    # @return [Integer] end position.
    def end_pos
      begin_pos
    end

  private

    # Indent of the node.
    #
    # @param node [Parser::AST::Node]
    # @return [String] n times whitesphace
    def indent(node)
      if [:block, :class].include? node.type
        ' ' * (node.indent + 2)
      else
        ' ' * node.indent
      end
    end
  end

  # InsertAction to insert code to the top of node body.
  class Rewriter::InsertAction < Rewriter::Action
    # Begin position to insert code.
    #
    # @return [Integer] begin position.
    def begin_pos
      insert_position(@node)
    end

    # End position, always same to begin position.
    #
    # @return [Integer] end position.
    def end_pos
      begin_pos
    end

  private

    # Insert position.
    #
    # @return [Integer] insert position.
    def insert_position(node)
      case node.type
      when :block
        node.children[1].children.empty? ? node.children[0].loc.expression.end_pos + 3 : node.children[1].loc.expression.end_pos
      when :class
        node.children[1] ? node.children[1].loc.expression.end_pos : node.children[0].loc.expression.end_pos
      else
        node.children.last.loc.expression.end_pos
      end
    end

    # Indent of the node.
    #
    # @param node [Parser::AST::Node]
    # @return [String] n times whitesphace
    def indent(node)
      if [:block, :class].include? node.type
        ' ' * (node.indent + 2)
      else
        ' ' * node.indent
      end
    end
  end

  # InsertAfterAction to insert code next to the node.
  class Rewriter::InsertAfterAction < Rewriter::Action
    # Begin position to insert code.
    #
    # @return [Integer] begin position.
    def begin_pos
      @node.loc.expression.end_pos
    end

    # End position, always same to begin position.
    #
    # @return [Integer] end position.
    def end_pos
      begin_pos
    end

  private

    # Indent of the node.
    #
    # @param node [Parser::AST::Node]
    # @return [String] n times whitesphace
    def indent(node)
      ' ' * node.indent
    end
  end

  # RemoveAction to remove code.
  class Rewriter::RemoveAction < Rewriter::Action
    def initialize(instance, code=nil)
      super
    end

    # Begin position of code to replace.
    #
    # @return [Integer] begin position.
    def begin_pos
      @node.loc.expression.begin_pos
    end

    # End position of code to replace.
    #
    # @return [Integer] end position.
    def end_pos
      @node.loc.expression.end_pos
    end

    # The rewritten code, always empty string.
    def rewritten_code
      ''
    end
  end
end
