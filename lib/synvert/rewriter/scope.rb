# encoding: utf-8

module Synvert
  class Rewriter::Scope
    def initialize(instance, options, &block)
      @instance = instance
      @options = options
      @block = block
    end

    def matching_nodes(nodes)
      @instance.instance_eval &@block
      matching_nodes = []
      while node = nodes.shift
        matching_nodes << node if node.match?(@options)
        node.recursive_children do |child_node|
          matching_nodes << child_node if child_node.match?(@options)
        end
      end
      matching_nodes
    end
  end
end
