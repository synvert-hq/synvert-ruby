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
        if (rewriter = @rewriters[name.to_s])
          rewriter.process
          rewriter
        else
          raise RewriterNotFound.new "Rewriter #{name} not found"
        end
      end

      def availables
        @rewriters.values
      end

      def clear
        @rewriters.clear
      end
    end

    attr_reader :name, :description, :todo_list

    def initialize(name, description, &block)
      @name = name
      @description = description
      @block = block
      @helpers = []
      self.class.register(name, self)
    end

    def process
      self.instance_eval &@block
    end

    def if_gem(name, comparator)
      @gem_spec = Rewriter::GemSpec.new(name, comparator)
    end

    def within_file(file_pattern, &block)
      if !@gem_spec || @gem_spec.match?
        instance = Rewriter::Instance.new(file_pattern, &block)
        @helpers.each { |helper| instance.singleton_class.send(:define_method, helper[:name], &helper[:block]) }
        instance.process
      end
    end

    alias within_files within_file

    def add_file(file, content)
      File.open file, 'w' do |file|
        file.write content
      end
    end

    def add_snippet(name)
      self.class.call(name)
    end

    def helper_method(name, &block)
      @helpers << {name: name, block: block}
    end

    def todo(list)
      @todo_list = list
    end
  end
end
