# coding: utf-8
require "synvert/version"
require 'bundler'
require 'parser'
require 'parser/current'
require 'ast'
require 'active_support/inflector'
require 'synvert/node_ext'

module Synvert
  autoload :CheckingVisitor, 'synvert/checking_visitor'
  autoload :Configuration, 'synvert/configuration'
  autoload :Rewriter, 'synvert/rewriter'
  autoload :RewriterNotFound, 'synvert/exceptions'
  autoload :GemfileLockNotFound, 'synvert/exceptions'
end
