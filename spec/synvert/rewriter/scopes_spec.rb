require 'spec_helper'

module Synvert
  describe Rewriter::Scopes do
    let(:source) {
"""
describe Post do
  before :each do
    @user = FactoryGirl.create :user
  end

  it 'gets posts' do
    post1 = FactoryGirl.create :post
    post2 = FactoryGirl.create :post
  end
end
"""
    }
    let(:node) { Parser::CurrentRuby.parse(source) }

    before(:each) { @scopes = Rewriter::Scopes.new }

    describe '#matching_nodes' do
      it 'gets original node if scopes are empty' do
        scoped_nodes = @scopes.matching_nodes(node)
        expect(scoped_nodes).to eq [node]
      end

      it 'gets all matching nodes with one scope' do
        @scopes.add type: 'send', receiver: 'FactoryGirl', message: 'create'
        scoped_nodes = @scopes.matching_nodes(node)
        expect(scoped_nodes.size).to eq 3
      end

      it 'gets all matching nodes with multi scopes' do
        @scopes.add type: 'block', caller: {message: 'describe', arguments: ['Post']}
        @scopes.add type: 'block', caller: {message: 'before', arguments: [':each']}
        @scopes.add type: 'send', receiver: 'FactoryGirl', message: 'create'
        scoped_nodes = @scopes.matching_nodes(node)
        expect(scoped_nodes.size).to eq 1
      end
    end
  end

  describe Rewriter::Scope do
    let(:source) {
"""
describe Post do
  before :each do
    @user = FactoryGirl.create :user
  end

  it 'gets posts' do
    post1 = FactoryGirl.create :post
    post2 = FactoryGirl.create :post
  end
end
"""
    }
    let(:node) { Parser::CurrentRuby.parse(source) }

    describe '#matching_nodes' do
      it 'gets empty array if does not match anything' do
        scope = Rewriter::Scope.new type: 'send', message: 'missing'
        expect(scope.matching_nodes([node])).to eq []
      end

      it 'gets matching nodes' do
        scope = Rewriter::Scope.new type: 'send', receiver: 'FactoryGirl', message: 'create', arguments: [':post']
        expect(scope.matching_nodes([node]).size).to eq 2
      end

      it 'gets matching nodes witch block caller' do
        scope = Rewriter::Scope.new type: 'block', caller: {message: 'it', arguments: ['gets posts']}
        expect(scope.matching_nodes([node]).size).to eq 1
      end
    end
  end
end
