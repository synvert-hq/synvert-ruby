require 'spec_helper'

module Synvert
  describe Rewriter::ReplaceWithAction do
    describe '#rewrite' do
      it 'replaces code' do
        action = Rewriter::ReplaceWithAction.new('create_list {{arguments}}')
        source = "post = FactoryGirl.create_list :post, 2"
        send_node = Parser::CurrentRuby.parse(source).children[1]
        output = action.rewrite(source, send_node)
        expect(output).to eq "post = create_list :post, 2"
      end
    end
  end

  describe Rewriter::InsertAction do
    describe '#rewrite' do
      it 'insert code to block node' do
        action = Rewriter::InsertAction.new('{{arguments.first}}.include FactoryGirl::Syntax::Methods')
        source = "RSpec.configure do |config|\nend"
        block_node = Parser::CurrentRuby.parse(source)
        output = action.rewrite(source, block_node)
        expect(output).to eq "RSpec.configure do |config|\n  config.include FactoryGirl::Syntax::Methods\nend"
      end

      it 'insert code to class node' do
        action = Rewriter::InsertAction.new('include FactoryGirl::Syntax::Methods')
        source = "class Test::Unit::TestCase\nend"
        block_node = Parser::CurrentRuby.parse(source)
        output = action.rewrite(source, block_node)
        expect(output).to eq "class Test::Unit::TestCase\n  include FactoryGirl::Syntax::Methods\nend"
      end

      it 'insert code to begin node' do
        action = Rewriter::InsertAction.new('World(FactoryGirl::Syntax::Methods)')
        source = "require 'cucumber/rails'\nActionController::Base.allow_rescue = false"
        block_node = Parser::CurrentRuby.parse(source)
        output = action.rewrite(source, block_node)
        expect(output).to eq "require 'cucumber/rails'\nActionController::Base.allow_rescue = false\nWorld(FactoryGirl::Syntax::Methods)"
      end

      it 'insert code to other node' do
        action = Rewriter::InsertAction.new('World(FactoryGirl::Syntax::Methods)')
        source = "require 'cucumber/rails'"
        block_node = Parser::CurrentRuby.parse(source)
        output = action.rewrite(source, block_node)
        expect(output).to eq "require 'cucumber/rails'\nWorld(FactoryGirl::Syntax::Methods)"
      end
    end
  end

  describe Rewriter::InsertAfterAction do
    describe '#rewrite' do
      it 'insert_after code' do
        action = Rewriter::InsertAfterAction.new('include Bar')
        source = "  include Foo"
        node = Parser::CurrentRuby.parse(source)
        output = action.rewrite(source, node)
        expect(output).to eq "  include Foo\n  include Bar"
      end
    end
  end

  describe Rewriter::RemoveAction do
    describe '#rewrite' do
      it 'remove code' do
        action = Rewriter::RemoveAction.new
        source = "user = User.new params[:user]\nuser.save\nrender\n"
        send_node = Parser::CurrentRuby.parse(source).children[1]
        output = action.rewrite(source, send_node)
        expect(output).to eq "user = User.new params[:user]\nrender\n"
      end
    end
  end
end
