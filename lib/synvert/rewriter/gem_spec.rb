# encoding: utf-8

module Synvert
  class Rewriter::GemSpec
    def initialize(name, version)
      @name = name
      @version = Gem::Version.new version
    end

    def match?
      gemfile_lock_path = File.join(Configuration.instance.get(:path), 'Gemfile.lock')
      if File.exists? gemfile_lock_path
        parser = Bundler::LockfileParser.new(File.read(gemfile_lock_path))
        Gem::Version.new(parser.specs.find { |spec| spec.name == @name }.version) >= @version
      else
        raise LoadError.new 'Gemfile.lock does not exist'
      end
    end
  end
end
