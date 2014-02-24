# coding: utf-8

module Synvert
  module FactoryGirl
    class SyntaxMethodsConverter < BaseConverter
      def interesting_files
        [/spec\/spec_helper\.rb/, /spec\/support\/.*\.rb/, /spec\/.*_spec\.rb/] +
          [/test\/test_helper\.rb/, /test\/support\/.*\.rb/, /test\/.*_test\.rb/] +
          [/features\/support\/env\.rb/, /features\/.*\.rb/]
      end

      def on_class(node)
        if (name(node) == to_ast("ActiveSupport::TestCase") || name(node) == to_ast("Test::Unit::TestCase")) &&
           !contains_statement?(body(node), "include FactoryGirl::Syntax::Methods")
          append_to node, "include FactoryGirl::Syntax::Methods"
        end

        super
      end

      def on_block(node)
        if receiver(node) == to_ast("RSpec") &&
           message(node) == :configure &&
           !contains_statement?(body(node), "config.include FactoryGirl::Syntax::Methods")
          append_to node, "config.include FactoryGirl::Syntax::Methods"
        end

        super
      end

      def on_send(node)
        if receiver(node) == to_ast("FactoryGirl") &&
           [:create, :build, :attributes_for, :build_stubbed, :create_list, :build_list, :create_pair, :build_pair].include?(message(node))
          replace node.loc.expression.resize("FactoryGirl.".size), ''
        end

        super
      end

      def on_program(node)
        if filename == "features/support/env.rb" && !contains_statement?(node, "World(FactoryGirl::Syntax::Methods)")
          append_after node.children[0], "World(FactoryGirl::Syntax::Methods)"
        end

        node.updated(nil, process_all(node))
      end
    end
  end
end
