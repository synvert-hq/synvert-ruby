# coding: utf-8

module Synvert
  module FactoryGirl
    class SyntaxMethodsConverter < Parser::Rewriter
      include AST::Sexp

      def interesting_files
        [/spec\/spec_helper\.rb/, /spec\/support\/.*\.rb/, /spec\/.*_spec\.rb/] +
          [/test\/test_helper\.rb/, /test\/support\/.*\.rb/, /test\/.*_test\.rb/]
      end

      def on_class(node)
        if (class_name(node) == to_ast("ActiveSupport::TestCase") || class_name(node) == to_ast("Test::Unit::TestCase")) &&
           contains_statement?(class_body(node), "include FactoryGirl::Syntax::Methods")
          class_indent = node.loc.expression.column
          new_code_indent = class_indent + 2
          insert_after node.children[0].loc.expression, "\n#{' '*new_code_indent}include FactoryGirl::Syntax::Methods"
        end

        super
      end

      def on_block(node)
        if block_send_receiver(node) == to_ast("RSpec") &&
           block_send_message(node) == :configure &&
           contains_statement?(block_body(node), "config.include FactoryGirl::Syntax::Methods")
          block_indent = node.loc.expression.column
          new_code_indent = block_indent + 2
          insert_after node.children[1].loc.expression, "\n#{' '*new_code_indent}config.include FactoryGirl::Syntax::Methods"
        end

        super
      end

      def on_send(node)
        if send_receiver(node) == to_ast("FactoryGirl") &&
           [:create, :build, :attributes_for, :build_stubbed].include?(send_message(node))
          replace node.children[0].loc.expression.resize(12), ''
        end

        super
      end

    private
      def class_name(node)
        node.children[0]
      end

      def class_body(node)
        node.children[1]
      end

      def block_send_receiver(node)
        send_receiver(node.children[0])
      end

      def block_send_message(node)
        send_message(node.children[0])
      end

      def block_body(node)
        node.children[2]
      end

      def send_receiver(node)
        node.children[0]
      end

      def send_message(node)
        node.children[1]
      end

      def contains_statement?(node, statement)
        !node || (node.type == :begin ? node.children : [node]).none? { |child_node|
          child_node == to_ast(statement)
        }
      end

      def to_ast(str)
        Parser::CurrentRuby.parse(str)
      end
    end
  end
end
