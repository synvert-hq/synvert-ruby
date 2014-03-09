# encoding: utf-8
require 'singleton'

module Synvert
  class Configuration < Hash
    include Singleton

    def set(key, value)
      self[key] = value
    end

    def get(key)
      self[key]
    end
  end
end
