module Synvert
  class Rewriter
    autoload :Action, 'synvert/rewriter/action'
    autoload :InsertAction, 'synvert/rewriter/action'
    autoload :ReplaceWithAction, 'synvert/rewriter/action'
    autoload :RemoveAction, 'synvert/rewriter/action'

    autoload :Instances, 'synvert/rewriter/instances'

    autoload :Scopes, 'synvert/rewriter/scopes'
    autoload :Scope, 'synvert/rewriter/scopes'

    autoload :Conditions, 'synvert/rewriter/conditions'
    autoload :Condition, 'synvert/rewriter/conditions'
    autoload :UnlessExistCondition, 'synvert/rewriter/conditions'

    autoload :GemSpec, 'synvert/rewriter/gem_spec'

    attr_reader :description

    def initialize(description, &block)
      @description = description
      @instances = Instances.new
      instance_eval &block if block_given?
    end

    def process
      @instances.process if @gem_spec.match?
    end

    def gem_spec(name, version)
      @gem_spec = Rewriter::GemSpec.new(name, version)
    end

    def within_file(file, &block)
      @instances.add(file, &block)
    end

    def within_files(files, &block)
      @instances.add(files, &block)
    end
  end
end
