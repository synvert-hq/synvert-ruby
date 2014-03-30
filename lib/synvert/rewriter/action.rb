# encoding: utf-8

module Synvert
  class Rewriter::Action
    def initialize(instance, code)
      @instance = instance
      @code = code
      @node = @instance.current_node
    end

    def line
      @node.loc.expression.line
    end

    def rewritten_code
      if rewritten_source.split("\n").length > 1
        "\n\n" + rewritten_source.split("\n").map { |line|
          indent(@node) + line
        }.join("\n")
      else
        "\n" + indent(@node) + rewritten_source
      end
    end

    def rewritten_source
      @rewritten_source ||= @node.rewritten_source(@code)
    end

    def <=>(action)
      self.begin_pos <=> action.begin_pos
    end
  end

  class Rewriter::ReplaceWithAction < Rewriter::Action
    def begin_pos
      @node.loc.expression.begin_pos
    end

    def end_pos
      @node.loc.expression.end_pos
    end

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

    def indent(node)
      ' ' * node.indent
    end
  end

  class Rewriter::AppendAction < Rewriter::Action
    def begin_pos
      if :begin == @node.type
        @node.loc.expression.end_pos
      else
        @node.loc.expression.end_pos - 4
      end
    end

    def end_pos
      begin_pos
    end

  private

    def indent(node)
      if [:block, :class].include? node.type
        ' ' * (node.indent + 2)
      else
        ' ' * node.indent
      end
    end
  end

  class Rewriter::InsertAction < Rewriter::Action
    def begin_pos
      insert_position(@node)
    end

    def end_pos
      begin_pos
    end

  private

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

    def indent(node)
      if [:block, :class].include? node.type
        ' ' * (node.indent + 2)
      else
        ' ' * node.indent
      end
    end
  end

  class Rewriter::InsertAfterAction < Rewriter::Action
    def begin_pos
      @node.loc.expression.end_pos
    end

    def end_pos
      begin_pos
    end

  private

    def indent(node)
      ' ' * node.indent
    end
  end

  class Rewriter::RemoveAction < Rewriter::Action
    def initialize(instance, code=nil)
      super
    end

    def begin_pos
      @node.loc.expression.begin_pos
    end

    def end_pos
      @node.loc.expression.end_pos
    end

    def rewritten_code
      ''
    end
  end
end
