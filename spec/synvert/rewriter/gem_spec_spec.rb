require 'spec_helper'

module Synvert
  describe Rewriter::GemSpec do
    before { Configuration.instance.set :path, '.' }
    let(:gemfile_lock_content) { """
GEM
  remote: https://rubygems.org/
  specs:
    ast (1.1.0)
    parser (2.1.7)
      ast (~> 1.1)
      slop (~> 3.4, >= 3.4.5)
    rake (10.1.1)
    slop (3.4.7)
      """}

    it 'returns true if version in Gemfile.lock is greater than definition' do
      expect(File).to receive(:exists?).with('./Gemfile.lock').and_return(true)
      expect(File).to receive(:read).with('./Gemfile.lock').and_return(gemfile_lock_content)
      gem_spec = Rewriter::GemSpec.new('ast', '1.0.0')
      expect(gem_spec).to be_match
    end

    it 'returns true if version in Gemfile.lock is equal to definition' do
      expect(File).to receive(:exists?).with('./Gemfile.lock').and_return(true)
      expect(File).to receive(:read).with('./Gemfile.lock').and_return(gemfile_lock_content)
      gem_spec = Rewriter::GemSpec.new('ast', '1.1.0')
      expect(gem_spec).to be_match
    end

    it 'returns false if version in Gemfile.lock is less than definition' do
      expect(File).to receive(:exists?).with('./Gemfile.lock').and_return(true)
      expect(File).to receive(:read).with('./Gemfile.lock').and_return(gemfile_lock_content)
      gem_spec = Rewriter::GemSpec.new('ast', '1.2.0')
      expect(gem_spec).not_to be_match
    end

    it 'returns false if gem does not exist in Gemfile.lock' do
      expect(File).to receive(:exists?).with('./Gemfile.lock').and_return(true)
      expect(File).to receive(:read).with('./Gemfile.lock').and_return(gemfile_lock_content)
      gem_spec = Rewriter::GemSpec.new('synvert', '1.0.0')
      expect(gem_spec).not_to be_match
    end

    it 'raise LoadError if Gemfile.lock does not exist' do
      expect(File).to receive(:exists?).with('./Gemfile.lock').and_return(false)
      gem_spec = Rewriter::GemSpec.new('ast', '1.1.0')
      expect { gem_spec.match? }.to raise_error(LoadError)
    end
  end
end
