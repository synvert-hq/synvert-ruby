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
    it 'gets for block node' do
      node = parse('RSpec.configure do |config|; include EmailSpec::Helpers; end')
      expect(node.body).to eq parse('include EmailSpec::Helpers')
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
end
