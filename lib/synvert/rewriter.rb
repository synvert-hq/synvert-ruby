# encoding: utf-8

module Synvert
  # Rewriter is the top level namespace in a snippet.
  #
  # One Rewriter can contain one or many [Synvert::Rewriter::Instance],
  # which define the behavior what files and what codes to detect and rewrite to what code.
  #
  #   Synvert::Rewriter.new 'factory_girl_short_syntax', 'use FactoryGirl short syntax' do
  #     if_gem 'factory_girl', {gte: '2.0.0'}
  #
  #     within_files 'spec/**/*.rb' do
  #       with_node type: 'send', receiver: 'FactoryGirl', message: 'create' do
  #         replace_with "create({{arguments}})"
  #       end
  #     end
  #   end
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
      # Register a rewriter with its name.
      #
      # @param name [String] the unique rewriter name.
      # @param rewriter [Synvert::Rewriter] the rewriter to register.
      def register(name, rewriter)
        @rewriters ||= {}
        @rewriters[name.to_s] = rewriter
      end

      # Get a registered rewriter by name and process that rewriter.
      #
      # @param name [String] the rewriter name.
      # @return [Synvert::Rewriter] the registered rewriter.
      # @raise [Synvert::RewriterNotFound] if the registered rewriter is not found.
      def call(name)
        if (rewriter = @rewriters[name.to_s])
          rewriter.process
          rewriter
        else
          raise RewriterNotFound.new "Rewriter #{name} not found"
        end
      end

      # Get all available rewriters
      #
      # @return [Array<Synvert::Rewriter>]
      def availables
        @rewriters.values
      end

      # Clear all registered rewriters.
      def clear
        @rewriters.clear
      end
    end

    # @!attribute [r] name
    #   @return [String] the unique name of rewriter
    attr_reader :name

    # Initialize a rewriter.
    # When a rewriter is initialized, it is also registered.
    #
    # @param name [String] name of the rewriter.
    # @param block [Block] a block defines the behaviors of the rewriter, block code won't be called when initialization.
    # @return [Synvert::Rewriter]
    def initialize(name, &block)
      @name = name
      @block = block
      @helpers = []
      self.class.register(name, self)
    end

    # Process the rewriter.
    # It will call the block.
    def process
      self.instance_eval &@block
    end

    #######
    # DSL #
    #######

    # Parse description dsl, it sets description of the rewrite.
    # Or get description.
    #
    # @param description [String] rewriter description.
    # @return rewriter description.
    def description(description=nil)
      if description
        @description = description
      else
        @description
      end
    end

    # Parse if_gem dsl, it compares version of the specified gem.
    #
    # @param name [String] gem name.
    # @param comparator [Hash] equal, less than or greater than specified version, e.g. {gte: '2.0.0'},
    #   key can be eq, lt, gt, lte, gte or ne.
    def if_gem(name, comparator)
      @gem_spec = Rewriter::GemSpec.new(name, comparator)
    end

    # Parse within_files dsl, it finds specified files.
    # It creates a [Synvert::Rewriter::Instance] to rewrite code.
    #
    # @param file_pattern [String] pattern to find files, e.g. spec/**/*_spec.rb
    # @param block [Block] the block to rewrite code in the matching files.
    def within_files(file_pattern, &block)
      if !@gem_spec || @gem_spec.match?
        instance = Rewriter::Instance.new(file_pattern, &block)
        @helpers.each { |helper| instance.singleton_class.send(:define_method, helper[:name], &helper[:block]) }
        instance.process
      end
    end

    # Parse within_file dsl, it finds a specifiled file.
    alias within_file within_files

    # Parses add_file dsl, it adds a new file.
    #
    # @param filename [String] file name of newly created file.
    # @param content [String] file body of newly created file.
    def add_file(filename, content)
      File.open filename, 'w' do |file|
        file.write content
      end
    end

    # Parse add_snippet dsl, it calls anther rewriter.
    #
    # @param name [String] name of another rewriter.
    def add_snippet(name)
      self.class.call(name)
    end

    # Parse helper_method dsl, it defines helper method for [Synvert::Rewriter::Instance].
    #
    # @param name [String] helper method name.
    # @param block [Block] helper method block.
    def helper_method(name, &block)
      @helpers << {name: name, block: block}
    end

    # Parse todo dsl, it sets todo of the rewriter.
    # Or get todo.
    #
    # @param todo_list [String] rewriter todo.
    # @return [String] rewriter todo.
    def todo(todo=nil)
      if todo
        @todo = todo
      else
        @todo
      end
    end
  end
end
