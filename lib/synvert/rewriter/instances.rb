# encoding: utf-8

module Synvert
  class Rewriter::Instances
    def initialize
      @instances = []
    end

    def add(file_pattern, &block)
      instance = Rewriter::Instance.new(file_pattern)
      instance.instance_eval &block if block_given?
      @instances << instance
    end

    def process
      @instances.each { |instance| instance.process }
    end
  end

  class Rewriter::Instance
    def initialize(file_pattern)
      @file_pattern = file_pattern
      @scopes = Rewriter::Scopes.new
      @conditions = Rewriter::Conditions.new
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

        scoped_nodes = @scopes.matching_nodes(ast)
        matching_nodes = @conditions.matching_nodes(scoped_nodes)
        matching_nodes.reverse.each do |node|
          source = @action.rewrite(source, node)
        end
        File.write path, source
      end
    end

    def within_node(options, &block)
      @scopes.add(options)
      instance_eval &block if block_given?
    end

    alias with_node within_node

    def unless_exist_node(options, &block)
      @conditions.add(Rewriter::UnlessExistCondition.new(options))
      instance_eval &block if block_given?
    end

    def if_only_exist_node(options, &block)
      @conditions.add(Rewriter::IfOnlyExistCondition.new(options))
      instance_eval &block if block_given?
    end

    def insert(code)
      @action = Rewriter::InsertAction.new(code)
    end

    def replace_with(code)
      @action = Rewriter::ReplaceWithAction.new(code)
    end

    def remove
      @action = Rewriter::RemoveAction.new
    end
  end
end
