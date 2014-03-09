# coding: utf-8
require "synvert/version"
require 'parser'
require 'parser/current'
require 'ast'
require 'synvert/node_ext'

module Synvert
  autoload :BaseConverter, 'synvert/base_converter'
  autoload :CheckingVisitor, 'synvert/checking_visitor'
  autoload :Configuration, 'synvert/configuration'
  autoload :Rewriter, 'synvert/rewriter'
end
