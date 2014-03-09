module Synvert
  class Rewriter
    autoload :Action, 'synvert/rewriter/action'
    autoload :ReplaceWithAction, 'synvert/rewriter/action'
    autoload :InsertAction, 'synvert/rewriter/action'

    autoload :Instances, 'synvert/rewriter/instances'

    autoload :Scopes, 'synvert/rewriter/scopes'
    autoload :Scope, 'synvert/rewriter/scopes'

    autoload :Conditions, 'synvert/rewriter/conditions'
    autoload :Condition, 'synvert/rewriter/conditions'
    autoload :UnlessExistCondition, 'synvert/rewriter/conditions'

    attr_reader :description, :version, :instances

    def initialize(description, &block)
      @description = description
      @instances = Instances.new
      instance_eval &block if block_given?
    end

    def process
      @instances.process
    end

    def from_version(version)
      @version = Version.from_string(version)
    end

    def within_file(file, &block)
      @instances.add(file, &block)
    end

    def within_files(files, &block)
      @instances.add(files, &block)
    end

    class Version
      def self.from_string(version)
        self.new *version.split('.')
      end

      def initialize(major, minor, patch)
        @major = major
        @minor = minor
        @patch = patch
      end

      def to_s
        [@major, @minor, @patch].join('.')
      end
    end
  end
end
