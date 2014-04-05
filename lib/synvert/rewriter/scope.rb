# encoding: utf-8

module Synvert
  # Scope finds the child nodes which match rules.
  class Rewriter::Scope
    # Initialize a scope
    #
    # @param instance [Synvert::Rewriter::Instance]
    # @param rules [Hash]
    # @param block [Block]
    def initialize(instance, rules, &block)
      @instance = instance
      @rules = rules
      @block = block
    end

    # Find the matching nodes. It checks the current node and iterates all child nodes,
    # then run the block code for each matching node.
    def process
      current_node = @instance.current_node
      return unless current_node
      process_with_node current_node do
        matching_nodes = []
        matching_nodes << current_node if current_node.match? @instance, @rules
        current_node.recursive_children do |child_node|
          matching_nodes << child_node if child_node.match? @instance, @rules
        end
        matching_nodes.each do |matching_node|
          process_with_node matching_node do
            @instance.instance_eval &@block
          end
        end
      end
    end

  private

    # Set instance current node properly and process.
    # @param node [Parser::AST::Node]
    def process_with_node(node)
      @instance.current_node = node
      yield
      @instance.current_node = node
    end
  end
end
