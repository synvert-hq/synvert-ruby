require 'spec_helper'

module Synvert
  describe Rewriter do
    it 'parses description' do
      rewriter = Rewriter.new 'name' do
        description 'rewriter description'
      end
      rewriter.process
      expect(rewriter.description).to eq 'rewriter description'
    end

    it 'parses if_gem' do
      expect(Rewriter::GemSpec).to receive(:new).with('synvert', {gte: '1.0.0'})
      rewriter = Rewriter.new 'name' do
        if_gem 'synvert', {gte: '1.0.0'}
      end
      rewriter.process
    end

    describe 'parses within_file' do
      it 'does nothing if if_gem not match' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(false)
        expect_any_instance_of(Rewriter::Instance).not_to receive(:process)
        rewriter = Rewriter.new 'name' do
          if_gem 'synvert', '1.0.0'
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end

      it 'delegates process to instances if if_gem not exist' do
        expect_any_instance_of(Rewriter::Instance).to receive(:process)
        rewriter = Rewriter.new 'name' do
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end

      it 'delegates process to instances if if_gem matches' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(true)
        expect_any_instance_of(Rewriter::Instance).to receive(:process)
        rewriter = Rewriter.new 'name' do
          if_gem 'synvert', '1.0.0'
          within_file 'config/routes.rb' do; end
        end
        rewriter.process
      end

      it 'does nothing in sandbox mode' do
        expect_any_instance_of(Rewriter::GemSpec).not_to receive(:match?)
        expect_any_instance_of(Rewriter::Instance).not_to receive(:process)
        rewriter = Rewriter.new 'name' do
          if_gem 'synvert', '1.0.0'
          within_file 'config/routes.rb' do; end
        end
        rewriter.process_with_sandbox
      end
    end

    describe 'parses add_file' do
      it 'creates a new file' do
        rewriter = Rewriter.new 'rewriter2' do
          add_file './foo.bar', 'FooBar'
        end
        rewriter.process
        expect(File.read './foo.bar').to eq 'FooBar'
        FileUtils.rm './foo.bar'
      end

      it 'does nothing in sandbox mode' do
        rewriter = Rewriter.new 'rewriter2' do
          add_file './foo.bar', 'FooBar'
        end
        rewriter.process_with_sandbox
        expect(File.exist?('./foo.bar')).to be_false
      end
    end

    describe 'parses add_snippet' do
      it 'processes the rewritter' do
        rewriter1 = Rewriter.new 'rewriter1'
        rewriter2 = Rewriter.new 'rewriter2' do
          add_snippet :rewriter1
        end
        expect(rewriter1).to receive(:process)
        rewriter2.process
      end

      it 'raises RewriterNotFound' do
        rewriter = Rewriter.new 'name' do
          add_snippet :not_exist
        end
        expect { rewriter.process }.to raise_error(RewriterNotFound)
      end
    end

    it 'parses helper_method' do
      instance = double
      expect(Rewriter::Instance).to receive(:new).and_return(instance)
      expect(instance).to receive(:process)
      rewriter = Rewriter.new 'name' do
        helper_method 'dynamic_helper' do |arg1, arg2|
          'dynamic result'
        end
        within_file 'spec/spec_helper.rb' do; end
      end
      rewriter.process
      expect(instance.dynamic_helper('arg1', 'arg2')).to eq 'dynamic result'
    end

    it 'parses todo' do
      rewriter = Rewriter.new 'name' do
        todo "this rewriter doesn't do blah blah blah"
      end
      rewriter.process
      expect(rewriter.todo).to eq "this rewriter doesn't do blah blah blah"
    end

    describe 'class methods' do
      before :each do
        Rewriter.clear
      end

      it 'registers and fetches' do
        rewriter = Rewriter.new 'rewriter'
        expect(Rewriter.fetch('rewriter')).to eq rewriter
      end

      it 'registers and calls rewriter' do
        rewriter = Rewriter.new 'rewriter'
        expect(rewriter).to receive(:process)
        Rewriter.call 'rewriter'
      end

      it 'registers and lists all available rewriters' do
        rewriter1 = Rewriter.new 'rewriter1'
        rewriter2 = Rewriter.new 'rewriter2'
        expect(Rewriter.availables).to eq [rewriter1, rewriter2]
      end
    end
  end
end
