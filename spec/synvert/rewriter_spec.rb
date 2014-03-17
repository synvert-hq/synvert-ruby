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
        rewriter1 = Synvert::Rewriter.new 'rewriter1', 'description1'
        rewriter2 = Synvert::Rewriter.new 'rewriter2', 'description2' do
          add_snippet :rewriter1
        end
        expect(rewriter1).to receive(:process)
        rewriter2.process
      end

      it 'raises RewriterNotFound' do
        rewriter = Synvert::Rewriter.new 'name', 'description' do
          add_snippet :not_exist
        end
        expect { rewriter.process }.to raise_error(Synvert::RewriterNotFound)
      end
    end
  end
end
