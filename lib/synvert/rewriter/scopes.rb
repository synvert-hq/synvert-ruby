# encoding: utf-8

module Synvert
  class Rewriter::Scopes
    def initialize
      @scopes = []
    end

    def add(options)
      @scopes << Rewriter::Scope.new(options)
    end

    def matching_nodes(node)
      nodes = [node]
      @scopes.each do |scope|
        break if nodes.empty?
        nodes = scope.matching_nodes(nodes)
      end
      nodes
    end
  end

  class Rewriter::Scope
    def initialize(options)
      @options = options
    end

    def matching_nodes(nodes)
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
