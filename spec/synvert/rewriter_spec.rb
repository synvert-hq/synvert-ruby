require 'spec_helper'

module Synvert
  describe Rewriter do
    it 'parses gem_spec' do
      expect(Rewriter::GemSpec).to receive(:new).with('synvert', '1.0.0')
      rewriter = Rewriter.new 'name', 'description' do
        gem_spec 'synvert', '1.0.0'
      end
      rewriter.process
    end

    describe 'parses within_file' do
      it 'does nothing if gem_spec not match' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(false)
        expect_any_instance_of(Rewriter::Instance).not_to receive(:process)
        rewriter = Rewriter.new 'name', 'description' do
          gem_spec 'synvert', '1.0.0'
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end

      it 'delegates process to instances if gem_spec not exist' do
        expect_any_instance_of(Rewriter::Instance).to receive(:process)
        rewriter = Rewriter.new 'name', 'description' do
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end

      it 'delegates process to instances if gem_spec matches' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(true)
        expect_any_instance_of(Rewriter::Instance).to receive(:process)
        rewriter = Rewriter.new 'name', 'description' do
          gem_spec 'synvert', '1.0.0'
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end
    end

    describe 'parses add_snippet' do
      it 'process the rewritter' do
        rewriter1 = Rewriter.new 'rewriter1', 'description1'
        rewriter2 = Rewriter.new 'rewriter2', 'description2' do
          add_snippet :rewriter1
        end
        expect(rewriter1).to receive(:process)
        rewriter2.process
      end

      it 'raises RewriterNotFound' do
        rewriter = Rewriter.new 'name', 'description' do
          add_snippet :not_exist
        end
        expect { rewriter.process }.to raise_error(RewriterNotFound)
      end
    end

    describe 'parses helper_method' do
      it 'adds helper method to new instance' do
        instance = double
        expect(Rewriter::Instance).to receive(:new).and_return(instance)
        expect(instance).to receive(:process)
        rewriter = Rewriter.new 'name', 'description' do
          helper_method 'dynamic_helper' do |arg1, arg2|
            'dynamic result'
          end
          within_file 'spec/spec_helper.rb' do; end
        end
        rewriter.process
        expect(instance.dynamic_helper('arg1', 'arg2')).to eq 'dynamic result'
      end
    end

    describe 'parses todo' do
      it 'sets todo_list' do
        rewriter = Rewriter.new 'name', 'description' do
          todo "this rewriter doesn't do blah blah blah"
        end
        rewriter.process
        expect(rewriter.todo_list).to eq "this rewriter doesn't do blah blah blah"
      end
    end

    describe 'class methods' do
      before :each do
        Rewriter.clear
      end

      it 'registers and calls rewriter' do
        rewriter = Rewriter.new 'rewriter', 'description'
        expect(rewriter).to receive(:process)
        Rewriter.call 'rewriter'
      end

      it 'registers and list all available rewriters' do
        rewriter1 = Rewriter.new 'rewriter1', 'description1'
        rewriter2 = Rewriter.new 'rewriter2', 'description2'
        expect(Rewriter.availables).to eq [rewriter1, rewriter2]
      end
    end
  end
end
