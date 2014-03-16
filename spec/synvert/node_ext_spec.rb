require 'spec_helper'

describe Parser::AST::Node do
  describe '#name' do
    it 'gets for class node' do
      node = parse('class Synvert; end')
      expect(node.name).to eq parse('Synvert')

      node = parse('class Synvert::Rewriter::Instance; end')
      expect(node.name).to eq parse('Synvert::Rewriter::Instance')
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
      node = parse('RSpec.configure do |config|; end')
      expect(node.arguments.map(&:to_s)).to eq ['config']
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

  describe '#to_s' do
    it 'gets for const node' do
      node = parse('Synvert')
      expect(node.to_s).to eq 'Synvert'

      node = parse('Synvert::Rewriter::Instance')
      expect(node.to_s).to eq 'Synvert::Rewriter::Instance'
    end

    it 'gets for sym node' do
      node = parse(':synvert')
      expect(node.to_s).to eq ':synvert'
    end

    it 'gets for str node' do
      node = parse("'synvert'")
      expect(node.to_s).to eq "'synvert'"
    end

    it 'gets for lvar node' do
      node = parse("user = User.find 1; user.valid?").grep_node(type: 'lvar')
      expect(node.to_s).to eq 'user'
    end

    it 'gets for ivar node' do
      node = parse('@user')
      expect(node.to_s).to eq '@user'
    end

    it 'gets for arg node' do
      node = parse("RSpec.configure do |config|; end").grep_node(type: 'arg')
      expect(node.to_s).to eq 'config'
    end

    it 'gets for self node' do
      node = parse('self')
      expect(node.to_s).to eq 'self'
    end

    it 'gets for true node' do
      node = parse('true')
      expect(node.to_s).to eq 'true'
    end

    it 'gets for false node' do
      node = parse('false')
      expect(node.to_s).to eq 'false'
    end

    it 'gets for send node' do
      node = parse('email')
      expect(node.to_s).to eq 'email'
    end
  end

  describe '#indent' do
    it 'gets column number' do
      node = parse('  FactoryGirl.create :post')
      expect(node.indent).to eq 2
    end
  end
end
