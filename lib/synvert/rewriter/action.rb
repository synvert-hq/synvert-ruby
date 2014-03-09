# encoding: utf-8

module Synvert
  class Rewriter::Action
    def initialize(code)
      @code = code
    end

    def rewrite(source, node)
      raise NotImplementedError.new 'rewrite method is not implemented'
    end
  end

  class Rewriter::ReplaceWithAction < Rewriter::Action
    def rewrite(source, node)
      begin_pos = node.loc.expression.begin_pos
      end_pos = node.loc.expression.end_pos
      source[begin_pos...end_pos] = node.to_source(@code)
      source
    end
  end

  class Rewriter::InsertAction < Rewriter::Action
    def rewrite(source, node)
      source[insert_position(node), 0] = "\n" + insert_indent(node) + node.to_source(@code)
      source
    end

    def insert_position(node)
      case node.type
      when :block
        node.children[1].loc.expression.end_pos
      when :class
        node.children[0].loc.expression.end_pos
      else
        node.children.last.loc.expression.end_pos
      end
    end

    def insert_indent(node)
      if [:block, :class].include? node.type
        ' ' * (node.indent + 2)
      else
        ' ' * node.indent
      end
    end
  end
end
