# encoding: utf-8

module Synvert
  class Rewriter::Instance
    def initialize(file_pattern)
      @file_pattern = file_pattern
      @scopes_or_conditions = []
    end

    def process
      parser = Parser::CurrentRuby.new
      file_pattern = File.join(Configuration.instance.get(:path), @file_pattern)
      Dir.glob(file_pattern).each do |path|
        source = File.read(path)
        buffer = Parser::Source::Buffer.new path
        buffer.source = source

        parser.reset
        ast = parser.parse buffer

        matching_nodes = [ast]
        @scopes_or_conditions.each do |scope_or_condition|
          matching_nodes = scope_or_condition.matching_nodes(matching_nodes)
        end
        matching_nodes.reverse.each do |node|
          source = @action.rewrite(source, node)
        end
        File.write path, source
      end
    end

    def within_node(options, &block)
      @scopes_or_conditions << Rewriter::Scope.new(options)
      instance_eval &block if block_given?
    end

    alias with_node within_node

    def unless_exist_node(options, &block)
      @scopes_or_conditions << Rewriter::UnlessExistCondition.new(options)
      instance_eval &block if block_given?
    end

    def if_only_exist_node(options, &block)
      @scopes_or_conditions << Rewriter::IfOnlyExistCondition.new(options)
      instance_eval &block if block_given?
    end

    def insert(code)
      @action = Rewriter::InsertAction.new(code)
    end

    def insert_after(node)
      @action = Rewriter::InsertAfterAction.new(node)
    end

    def replace_with(code)
      @action = Rewriter::ReplaceWithAction.new(code)
    end

    def remove
      @action = Rewriter::RemoveAction.new
    end
  end
end
