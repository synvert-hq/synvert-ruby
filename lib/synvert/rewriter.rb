module Synvert
  class Rewriter
    autoload :Action, 'synvert/rewriter/action'
    autoload :AppendAction, 'synvert/rewriter/action'
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
      @block = block
      @assignments = {}
    end

    def set(name, key, value)
      @assignments[name] ||= {}
      @assignments[name][key] = value
    end

    def get(name, key)
      @assignments[name] and @assignments[name][key]
    end

    def process
      self.instance_eval &@block
    end

    def gem_spec(name, version)
      @gem_spec = Rewriter::GemSpec.new(name, version)
    end

    def within_file(file_pattern, &block)
      if @gem_spec.match?
        Rewriter::Instance.new(self, file_pattern, &block).process
      end
    end

    alias within_files within_file
  end
end
