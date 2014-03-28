# encoding: utf-8

module Synvert
  class Rewriter::Condition
    def initialize(instance, rules, &block)
      @instance = instance
      @rules = rules
      @block = block
    end

    def process
      @instance.instance_eval &@block if match?
    end
  end

  class Rewriter::IfExistCondition < Rewriter::Condition
    def match?
      match = false
      @instance.current_node.recursive_children do |child_node|
        match = match || (child_node && child_node.match?(@instance, @rules))
      end
      match
    end
  end

  class Rewriter::UnlessExistCondition < Rewriter::Condition
    def match?
      match = false
      @instance.current_node.recursive_children do |child_node|
        match = match || (child_node && child_node.match?(@instance, @rules))
      end
      !match
    end
  end

  class Rewriter::IfOnlyExistCondition < Rewriter::Condition
    def match?
      @instance.current_node.body.size == 1 &&
        @instance.current_node.body.first.match?(@instance, @rules)
    end
  end
end
