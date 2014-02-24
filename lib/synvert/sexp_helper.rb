module Synvert
  module SexpHelper
    def name(node)
      case node.type
      when :class
        node.children[0]
      else
      end
    end

    def body(node)
      case node.type
      when :class
        node.children[1]
      when :block
        node.children[2]
      else
      end
    end

    def receiver(node)
      case node.type
      when :send
        node.children[0]
      when :block
        receiver(node.children[0])
      else
      end
    end

    def message(node)
      case node.type
      when :send
        node.children[1]
      when :block
        message(node.children[0])
      else
      end
    end

    def contains_statement?(node, statement)
      node && (node.type == :begin ? node.children : [node]).any? { |child_node|
        child_node == to_ast(statement)
      }
    end

    def to_ast(str)
      Parser::CurrentRuby.parse(str)
    end
  end
end
