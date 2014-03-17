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
    autoload :IfExistCondition, 'synvert/rewriter/condition'
    autoload :UnlessExistCondition, 'synvert/rewriter/condition'
    autoload :IfOnlyExistCondition, 'synvert/rewriter/condition'

    autoload :GemSpec, 'synvert/rewriter/gem_spec'

    class <<self
      def register(name, rewriter)
        @rewriters ||= {}
        @rewriters[name.to_s] = rewriter
      end

      def call(name)
        if @rewriters[name.to_s]
          @rewriters[name.to_s].process
        else
          raise RewriterNotFound.new "Rewriter #{name} not found"
        end
      end
    end

    def initialize(name, description, &block)
      @name = name
      @description = description
      @block = block
      self.class.register(name, self)
    end

    def process
      self.instance_eval &@block
    end

    def gem_spec(name, version)
      @gem_spec = Rewriter::GemSpec.new(name, version)
    end

    def within_file(file_pattern, &block)
      if !@gem_spec || @gem_spec.match?
        Rewriter::Instance.new(file_pattern, &block).process
      end
    end

    alias within_files within_file

    def add_snippet(name)
      self.class.call(name)
    end
  end
end
