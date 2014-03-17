# encoding: utf-8

module Synvert
  class Rewriter::Condition
    def initialize(instance, options, &block)
      @instance = instance
      @options = options
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
        match = match || (child_node && child_node.match?(@instance, @options))
      end
      match
    end
  end

  class Rewriter::UnlessExistCondition < Rewriter::Condition
    def match?
      match = false
      @instance.current_node.recursive_children do |child_node|
        match = match || (child_node && child_node.match?(@instance, @options))
      end
      !match
    end
  end

  class Rewriter::IfOnlyExistCondition < Rewriter::Condition
    def match?
      :begin != @instance.current_node.body.type &&
        @instance.current_node.body.match?(@instance, @options)
    end
  end
end
