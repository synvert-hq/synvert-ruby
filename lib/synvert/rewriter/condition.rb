# encoding: utf-8

module Synvert
  # Condition checks if rules matches.
  class Rewriter::Condition
    # Initialize a condition.
    #
    # @param instance [Synvert::Rewriter::Instance]
    # @param rules [Hash]
    # @param block [Block]
    # @return [Synvert::Rewriter::Condition]
    def initialize(instance, rules, &block)
      @instance = instance
      @rules = rules
      @block = block
    end

    # If condition matches, run the block code.
    def process
      @instance.instance_eval &@block if match?
    end
  end

  # IfExistCondition checks if matching node exists in the node children.
  class Rewriter::IfExistCondition < Rewriter::Condition
    # check if any child node matches the rules.
    def match?
      match = false
      @instance.current_node.recursive_children do |child_node|
        match = match || (child_node && child_node.match?(@instance, @rules))
      end
      match
    end
  end

  # UnlessExistCondition checks if matching node doesn't exist in the node children.
  class Rewriter::UnlessExistCondition < Rewriter::Condition
    # check if none of child node matches the rules.
    def match?
      match = false
      @instance.current_node.recursive_children do |child_node|
        match = match || (child_node && child_node.match?(@instance, @rules))
      end
      !match
    end
  end

  # IfExistCondition checks if node has only one child node and the child node matches rules.
  class Rewriter::IfOnlyExistCondition < Rewriter::Condition
    # check if only have one child node and the child node matches rules.
    def match?
      @instance.current_node.body.size == 1 &&
        @instance.current_node.body.first.match?(@instance, @rules)
    end
  end
end
