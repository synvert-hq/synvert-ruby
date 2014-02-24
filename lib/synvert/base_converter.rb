# coding: utf-8

module Synvert
  class BaseConverter < Parser::Rewriter
    include AST::Sexp
    include SexpHelper

    attr_reader :filename

    def rewrite(source_buffer, ast)
      @filename = source_buffer.name

      new_ast = AST::Node.new(:program, [ast])
      super(source_buffer, new_ast)
    end

    def append_to(node, content)
      if node.children.last
        indent = indent(node.children.last)
        insert_after node.children.last.loc.expression, "\n#{' '*indent}#{content}"
      else
        indent = indent(node) + 2
        insert_after node.children.first.loc.expression, "\n#{' '*indent}#{content}"
      end
    end

    def append_after(node, content)
      indent = indent(node)
      insert_after node.loc.expression, "\n#{' '*indent}#{content}"
    end

    def indent(node)
      node.loc.expression.column
    end
  end
end
