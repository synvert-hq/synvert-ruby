require 'spec_helper'

module Synvert
  describe Rewriter::ReplaceWithAction do
    subject {
      source = "post = FactoryGirl.create_list :post, 2"
      send_node = Parser::CurrentRuby.parse(source).children[1]
      instance = double(:current_node => send_node)
      Rewriter::ReplaceWithAction.new(instance, 'create_list {{arguments}}')
    }

    it 'gets begin_pos' do
      expect(subject.begin_pos).to eq 7
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq 39
    end

    it 'gets rewritten_code' do
      expect(subject.rewritten_code).to eq 'create_list :post, 2'
    end
  end

  describe Rewriter::InsertAction do
    subject {
      source = "RSpec.configure do |config|\nend"
      block_node = Parser::CurrentRuby.parse(source)
      instance = double(:current_node => block_node)
      Rewriter::InsertAction.new(instance, '{{arguments.first}}.include FactoryGirl::Syntax::Methods')
    }

    it 'gets begin_pos' do
      expect(subject.begin_pos).to eq 27
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq 27
    end

    it 'gets rewritten_code' do
      expect(subject.rewritten_code).to eq "\n  config.include FactoryGirl::Syntax::Methods"
    end
  end

  describe Rewriter::InsertAfterAction do
    subject {
      source = "  include Foo"
      node = Parser::CurrentRuby.parse(source)
      instance = double(:current_node => node)
      Rewriter::InsertAfterAction.new(instance, 'include Bar')
    }

    it 'gets begin_pos' do
      expect(subject.begin_pos).to eq 13
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq 13
    end

    it 'gets rewritten_code' do
      expect(subject.rewritten_code).to eq "\n  include Bar"
    end
  end

  describe Rewriter::RemoveAction do
    subject {
      source = "user = User.new params[:user]\nuser.save\nrender\n"
      send_node = Parser::CurrentRuby.parse(source).children[1]
      instance = double(:current_node => send_node)
      Rewriter::RemoveAction.new(instance)
    }

    it 'gets begin_pos' do
      expect(subject.begin_pos).to eq 30
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq 39
    end

    it 'gets rewritten_code' do
      expect(subject.rewritten_code).to eq ""
    end
  end
end
