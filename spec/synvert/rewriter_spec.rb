require 'spec_helper'

module Synvert
  describe Rewriter do
    it 'sets description' do
      rewriter = Rewriter.new 'this is description' do; end
      expect(rewriter.description).to eq 'this is description'
    end

    it 'parses from_version' do
      rewriter = Rewriter.new 'description' do
        from_version '1.0.0'
      end
      expect(rewriter.version.to_s).to eq '1.0.0'
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
  end
end
