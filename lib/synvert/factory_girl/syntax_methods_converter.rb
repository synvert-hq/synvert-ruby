# coding: utf-8
require 'parser'
require 'ast'

module Synvert
  module FactoryGirl
    class SyntaxMethodsConverter < Parser::Rewriter
      include AST::Sexp

      def interesting_files
        [/spec\/spec_helper.rb/, /spec\/.*_spec.rb/]
      end

      def on_block(node)
        if block_send_receiver(node) == s(:const, nil, :RSpec) &&
          block_send_message(node) == :configure
          block_body_node = block_body(node)
          if !block_body_node || (block_body_node.type == :begin ? block_body_node.children : [block_body_node]).none? { |child_node|
            child_node == s(:send, s(:lvar, :config), :include, s(:const, s(:const, s(:const, nil, :FactoryGirl), :Syntax), :Methods))
          }
            block_indent = node.loc.expression.column
            new_code_indent = block_indent + 2
            insert_after node.children[1].loc.expression, "\n#{' '*new_code_indent}config.include FactoryGirl::Syntax::Methods"
          end
        end

        super
      end

      def on_send(node)
        if send_receiver(node) == s(:const, nil, :FactoryGirl) &&
          [:create, :build, :attributes_for, :build_stubbed].include?(send_message(node))
          replace node.children[0].loc.expression.resize(12), ''
        end

        super
      end

    private
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
    end
  end
end
