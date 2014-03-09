# encoding: utf-8

module Synvert
  class Rewriter::Conditions
    def initialize
      @conditions = []
    end

    def add(condition)
      @conditions << condition
    end

    def matching_nodes(nodes)
      @conditions.each do |condition|
        break if nodes.empty?
        nodes = condition.matching_nodes(nodes)
      end
      nodes
    end
  end

  class Rewriter::Condition
    def initialize(options)
      @options = options
    end
  end

  class Rewriter::UnlessExistCondition < Rewriter::Condition
    def matching_nodes(nodes)
      nodes.find_all { |node|
        match = false
        node.recursive_children do |child_node|
          match = match || (child_node && child_node.match?(@options))
        end
        !match
      }
    end
  end
end
