# frozen_string_literal: true

require 'synvert/version'
require 'bundler'
require 'synvert/core'

module Synvert
  autoload :CLI, 'synvert/cli'
  autoload :Utils, 'synvert/utils'
  autoload :Snippet, 'synvert/snippet'
end
