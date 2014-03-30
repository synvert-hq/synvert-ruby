# encoding: utf-8

module Synvert
  class Rewriter::GemSpec
    OPERATORS = {eq: '==', lt: '<', gt: '>', lte: '<=', gte: '>=', ne: '!='}
    def initialize(name, comparator)
      @name = name
      if Hash === comparator
        @operator = comparator.keys.first
        @version = Gem::Version.new comparator.values.first
      else
        @operator = :eq
        @version = Gem::Version.new comparator
      end
    end

    def match?
      gemfile_lock_path = File.join(Configuration.instance.get(:path), 'Gemfile.lock')
      if File.exists? gemfile_lock_path
        parser = Bundler::LockfileParser.new(File.read(gemfile_lock_path))
        if spec = parser.specs.find { |spec| spec.name == @name }
          Gem::Version.new(spec.version).send(OPERATORS[@operator], @version)
        else
          false
        end
      else
        raise LoadError.new 'Gemfile.lock does not exist'
      end
    end
  end
end
