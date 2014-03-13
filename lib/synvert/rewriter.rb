module Synvert
  class Rewriter
    autoload :Action, 'synvert/rewriter/action'
    autoload :InsertAction, 'synvert/rewriter/action'
    autoload :InsertAfterAction, 'synvert/rewriter/action'
    autoload :ReplaceWithAction, 'synvert/rewriter/action'
    autoload :RemoveAction, 'synvert/rewriter/action'

    autoload :Instance, 'synvert/rewriter/instance'

    autoload :Scope, 'synvert/rewriter/scope'

    autoload :Condition, 'synvert/rewriter/condition'
    autoload :UnlessExistCondition, 'synvert/rewriter/condition'
    autoload :IfOnlyExistCondition, 'synvert/rewriter/condition'

    autoload :GemSpec, 'synvert/rewriter/gem_spec'

    attr_reader :description

    def initialize(description, &block)
      @description = description
      @instances = []
      instance_eval &block if block_given?
    end

    def process
      if @gem_spec.match?
        @instances.each { |instance| instance.process }
      end
    end

    def gem_spec(name, version)
      @gem_spec = Rewriter::GemSpec.new(name, version)
    end

    def within_file(file_pattern, &block)
      instance = Rewriter::Instance.new(file_pattern)
      instance.instance_eval &block if block_given?
      @instances << instance
    end

    alias within_files within_file
  end
end
