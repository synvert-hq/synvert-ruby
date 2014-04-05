# encoding: utf-8
require 'singleton'

module Synvert
  # Synvert global configuration.
  class Configuration < Hash
    include Singleton

    # Set the configuration.
    #
    # @param key [String] configuration key.
    # @param value [Object] configuration value.
    def set(key, value)
      self[key] = value
    end

    # Get the configuration.
    #
    # @param key [String] configuration key.
    # @return [Object] configuration value.
    def get(key)
      self[key]
    end
  end
end
