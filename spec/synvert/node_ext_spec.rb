require 'spec_helper'

describe Parser::AST::Node do
  describe '#name' do
    it 'gets for class node' do
      node = parse('class Synvert; end')
      expect(node.name).to eq parse('Synvert')

      node = parse('class Synvert::Rewriter::Instance; end')
      expect(node.name).to eq parse('Synvert::Rewriter::Instance')
    end

    it 'gets for module node' do
      node = parse('module Synvert; end')
      expect(node.name).to eq parse('Synvert')
    end

    it 'gets for def node' do
      node = parse('def current_node; end')
      expect(node.name).to eq :current_node
    end

    it 'gets for defs node' do
      node = parse('def self.current_node; end')
      expect(node.name).to eq :current_node
    end
  end

  describe '#receiver' do
    it 'gets for send node' do
      node = parse('FactoryGirl.create :post')
      expect(node.receiver).to eq parse('FactoryGirl')
    end
  end

  describe '#message' do
    it 'gets for send node' do
      node = parse('FactoryGirl.create :post')
      expect(node.message).to eq :create
    end
  end

  describe '#arguments' do
    it 'gets for send node' do
      node = parse("FactoryGirl.create :post, title: 'post'")
      expect(node.arguments).to eq parse("[:post, title: 'post']").children
    end

    it 'gets for block node' do
      source = 'RSpec.configure do |config|; end'
      node = parse(source)
      instance = double(current_source: source)
      expect(node.arguments.map { |argument| argument.source(instance) }).to eq ['config']
    end

    it 'gets for defined? node' do
      node = parse('defined?(Bundler)')
      expect(node.arguments).to eq [parse('Bundler')]
    end
  end

  describe '#caller' do
    it 'gets for block node' do
      node = parse('RSpec.configure do |config|; end')
      expect(node.caller).to eq parse('RSpec.configure')
    end
  end

  describe '#body' do
    it 'gets one line for block node' do
      node = parse('RSpec.configure do |config|; include EmailSpec::Helpers; end')
      expect(node.body).to eq [parse('include EmailSpec::Helpers')]
    end

    it 'gets multiple lines for block node' do
      node = parse('RSpec.configure do |config|; include EmailSpec::Helpers; include EmailSpec::Matchers; end')
      expect(node.body).to eq [parse('include EmailSpec::Helpers'), parse('include EmailSpec::Matchers')]
    end

    it 'gets for begin node' do
      node = parse('foo; bar')
      expect(node.body).to eq [parse('foo'), parse('bar')]
    end
  end

  describe "#condition" do
    it 'gets for if node' do
      node = parse('if defined?(Bundler); end')
      expect(node.condition).to eq parse('defined?(Bundler)')
    end
  end

  describe '#source' do
    it 'gets for node' do
      source = 'params[:user][:email]'
      instance = double(current_source: source)
      node = parse(source)
      expect(node.source(instance)).to eq 'params[:user][:email]'
    end
  end

  describe '#indent' do
    it 'gets column number' do
      node = parse('  FactoryGirl.create :post')
      expect(node.indent).to eq 2
    end
  end

  describe '#recursive_children' do
    it 'iterates all children recursively' do
      node = parse('class Synvert; def current_node; @node; end; end')
      children = []
      node.recursive_children { |child| children << child.type }
      expect(children).to be_include :const
      expect(children).to be_include :def
      expect(children).to be_include :args
      expect(children).to be_include :ivar
    end
  end

  describe '#match?' do
    let(:instance) { Synvert::Rewriter::Instance.new('file pattern') }

    it 'matches class name' do
      source = 'class Synvert; end'
      instance.current_source = source
      node = parse(source)
      expect(node).to be_match(instance, type: 'class', name: 'Synvert')
    end

    it 'matches message with regexp' do
      source = 'User.find_by_login(login)'
      instance.current_source = source
      node = parse(source)
      expect(node).to be_match(instance, type: 'send', message: /^find_by_/)
    end

    it 'matches arguments with symbol' do
      source = 'params[:user]'
      instance.current_source = source
      node = parse(source)
      expect(node).to be_match(instance, type: 'send', receiver: 'params', message: '[]', arguments: [:user])
    end

    it 'matches arguments with string' do
      source = 'params["user"]'
      instance.current_source = source
      node = parse(source)
      expect(node).to be_match(instance, type: 'send', receiver: 'params', message: '[]', arguments: ['user'])
    end

    it 'matches arguments any' do
      source = 'config.middleware.insert_after ActiveRecord::QueryCache, Lifo::Cache, page_cache: false'
      instance.current_source = source
      node = parse(source)
      expect(node).to be_match(instance, type: 'send', arguments: {any: 'Lifo::Cache'})
    end

    it 'matches not' do
      source = 'class Synvert; end'
      instance.current_source = source
      node = parse(source)
      expect(node).not_to be_match(instance, type: 'class', name: {not: 'Synvert'})
    end
  end
end
