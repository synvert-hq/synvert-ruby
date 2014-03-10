require 'spec_helper'

module Synvert
  describe Rewriter do
    it 'sets description' do
      rewriter = Rewriter.new 'this is description' do; end
      expect(rewriter.description).to eq 'this is description'
    end

    it 'parses gem_spec' do
      expect(Rewriter::GemSpec).to receive(:new).with('synvert', '1.0.0')
      Rewriter.new 'description' do
        gem_spec 'synvert', '1.0.0'
      end
    end

    it 'parses within_file' do
      expect_any_instance_of(Rewriter::Instances).to receive(:add).with('spec/spec_helper.rb')
      Rewriter.new 'description' do
        within_file 'spec/spec_helper.rb' do; end
      end
    end

    it 'parses within_files' do
      expect_any_instance_of(Rewriter::Instances).to receive(:add).with('spec/**/*_spec.rb')
      Rewriter.new 'description' do
        within_files 'spec/**/*_spec.rb' do; end
      end
    end

    describe '#process' do
      it 'does nothing if gem_spec not match' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(false)
        expect_any_instance_of(Rewriter::Instances).not_to receive(:process)
        rewriter = Rewriter.new 'description' do
          gem_spec 'synvert', '1.0.0'
        end
        rewriter.process
      end

      it 'delegates process to instances' do
        expect_any_instance_of(Rewriter::GemSpec).to receive(:match?).and_return(true)
        expect_any_instance_of(Rewriter::Instances).to receive(:process)
        rewriter = Rewriter.new 'description' do
          gem_spec 'synvert', '1.0.0'
        end
        rewriter.process
      end
    end
  end
end
