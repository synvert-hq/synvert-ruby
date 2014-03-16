# encoding: utf-8

module Synvert
  class Rewriter::Scope
    def initialize(instance, options, &block)
      @instance = instance
      @options = options
      @block = block
    end

    def process
      current_node = @instance.current_node
      return unless current_node
      process_with_node current_node do
        matching_nodes = []
        matching_nodes << current_node if current_node.match? @instance, @options
        current_node.recursive_children do |child_node|
          matching_nodes << child_node if child_node.match? @instance, @options
        end
        matching_nodes.each do |matching_node|
          process_with_node matching_node do
            @instance.instance_eval &@block
          end
        end
      end
    end

  private

    def process_with_node(node)
      @instance.current_node = node
      yield
      @instance.current_node = node
    end
  end
end
