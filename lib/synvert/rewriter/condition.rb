# encoding: utf-8

module Synvert
  class Rewriter::Condition
    def initialize(instance, options, &block)
      @instance = instance
      @options = options
      @block = block
    end
  end

  class Rewriter::UnlessExistCondition < Rewriter::Condition
    def matching_nodes(nodes)
      @instance.instance_eval &@block
      nodes.find_all { |node|
        match = false
        node.recursive_children do |child_node|
          match = match || (child_node && child_node.match?(@options))
        end
        !match
      }
    end
  end

  class Rewriter::IfOnlyExistCondition < Rewriter::Condition
    def matching_nodes(nodes)
      @instance.instance_eval &@block
      nodes.find_all { |node|
        :begin != node.body.type && node.body.match?(@options)
      }
    end
  end
end
