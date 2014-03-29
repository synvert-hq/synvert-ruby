require 'spec_helper'

module Synvert
  describe Rewriter::ReplaceWithAction do
    context "replace with single line" do
      subject {
        source = "post = FactoryGirl.create_list :post, 2"
        send_node = Parser::CurrentRuby.parse(source).children[1]
        instance = double(:current_node => send_node)
        Rewriter::ReplaceWithAction.new(instance, 'create_list {{arguments}}')
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "post = ".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "post = FactoryGirl.create_list :post, 2".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq 'create_list :post, 2'
      end
    end

    context "#replace with multiple line" do
      subject {
        source = "  its(:size) { should == 1 }"
        send_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => send_node)
        Rewriter::ReplaceWithAction.new(instance, """describe '#size' do
  subject { super().size }
  it { {{body}} }
end""")
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq 2
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "  its(:size) { should == 1 }".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq """  describe '#size' do
    subject { super().size }
    it { should == 1 }
  end"""
      end
    end
  end

  describe Rewriter::AppendAction < Rewriter::Action do
    describe 'class node' do
      subject do
        source = "class User\n  has_many :posts\nend"
        class_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => class_node)
        Rewriter::AppendAction.new(instance, "def as_json\n  super\nend")
      end

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "calss User\n  has_many :posts".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "class User\n  has_many :posts".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\n\n  def as_json\n    super\n  end"
      end
    end

    describe 'begin node' do
      subject do
        source = "gem 'rails'\ngem 'mysql2'"
        begin_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => begin_node)
        Rewriter::AppendAction.new(instance, "gem 'twitter'")
      end

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "gem 'rails'\ngem 'mysql2'".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "gem 'rails'\ngem 'mysql2'".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\ngem 'twitter'"
      end
    end
  end

  describe Rewriter::InsertAction do
    describe 'block node without args' do
      subject {
        source = "Synvert::Application.configure do\nend"
        block_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => block_node)
        Rewriter::InsertAction.new(instance, 'config.eager_load = true')
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "Synvert::Application.configure do".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "Synvert::Application.configure do".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\n  config.eager_load = true"
      end
    end

    describe 'block node with args' do
      subject {
        source = "RSpec.configure do |config|\nend"
        block_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => block_node)
        Rewriter::InsertAction.new(instance, '{{arguments.first}}.include FactoryGirl::Syntax::Methods')
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "RSpec.configure do |config|".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "RSpec.configure do |config|".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\n  config.include FactoryGirl::Syntax::Methods"
      end
    end

    describe 'class node without superclass' do
      subject {
        source = "class User\n  has_many :posts\nend"
        class_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => class_node)
        Rewriter::InsertAction.new(instance, 'include Deletable')
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "class User".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "class User".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\n  include Deletable"
      end
    end

    describe 'class node with superclass' do
      subject {
        source = "class User < ActiveRecord::Base\n  has_many :posts\nend"
        class_node = Parser::CurrentRuby.parse(source)
        instance = double(:current_node => class_node)
        Rewriter::InsertAction.new(instance, 'include Deletable')
      }

      it 'gets begin_pos' do
        expect(subject.begin_pos).to eq "class User < ActionRecord::Base".length
      end

      it 'gets end_pos' do
        expect(subject.end_pos).to eq "class User < ActionRecord::Base".length
      end

      it 'gets rewritten_code' do
        expect(subject.rewritten_code).to eq "\n  include Deletable"
      end
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
      expect(subject.begin_pos).to eq "  include Foo".length
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq "  include Foo".length
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
      expect(subject.begin_pos).to eq "user = User.new params[:user]\n".length
    end

    it 'gets end_pos' do
      expect(subject.end_pos).to eq "user = User.new params[:user]\nuser.save".length
    end

    it 'gets rewritten_code' do
      expect(subject.rewritten_code).to eq ""
    end
  end
end
