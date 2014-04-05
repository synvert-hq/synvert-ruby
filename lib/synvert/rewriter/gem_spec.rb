# encoding: utf-8

module Synvert
  # GemSpec checks and compares gem version.
  class Rewriter::GemSpec
    OPERATORS = {eq: '==', lt: '<', gt: '>', lte: '<=', gte: '>=', ne: '!='}

    # Initialize a gem_spec.
    #
    # @param name [String] gem name
    # @param comparator [Hash] comparator to gem version, e.g. {eg: '2.0.0'},
    #   comparator key can be eq, lt, gt, lte, gte or ne.
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

    # Check if the specified gem version in Gemfile.lock matches gem_spec comparator.
    #
    # @return [Boolean] true if matches, otherwise false.
    # @raise [Synvert::GemfileLockNotFound] raise if Gemfile.lock does not exist.
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
        raise GemfileLockNotFound.new 'Gemfile.lock does not exist'
      end
    end
  end
end
