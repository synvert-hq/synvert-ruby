# coding: utf-8
require "synvert/version"
require 'parser'
require 'parser/current'
require 'ast'

module Synvert
  autoload :BaseConverter, 'synvert/base_converter'
  autoload :CheckingVisitor, 'synvert/checking_visitor'
  autoload :SexpHelper, 'synvert/sexp_helper'
  module FactoryGirl
    autoload :SyntaxMethodsConverter, 'synvert/factory_girl/syntax_methods_converter'
  end
end
