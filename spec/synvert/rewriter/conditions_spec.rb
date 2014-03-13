require 'spec_helper'

module Synvert
  describe Rewriter::Conditions do

  end

  describe Rewriter::UnlessExistCondition do
    let(:source) {
      """
      RSpec.configure do |config|
        config.include EmailSpec::Helpers
        config.include EmailSpec::Methods
      end
      """
    }
    let(:node) { Parser::CurrentRuby.parse(source) }

    describe '#matching_nodes' do
      it 'gets empty array if does not matchi anything' do
        condition = Rewriter::UnlessExistCondition.new type: 'send', message: 'include', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'} }
        expect(condition.matching_nodes([node]).size).to eq 1
      end

      it 'gets matching nodes' do
        condition = Rewriter::UnlessExistCondition.new type: 'send', message: 'include', arguments: {first: {to_s: 'EmailSpec::Helpers'} }
        expect(condition.matching_nodes([node])).to eq []
      end
    end
  end

  describe Rewriter::IfOnlyExistCondition do
    describe '#matching_nodes' do
      it 'gets matching nodes' do
        source = """
          RSpec.configure do |config|
            config.include EmailSpec::Helpers
          end
        """
        node = Parser::CurrentRuby.parse(source)

        condition = Rewriter::IfOnlyExistCondition.new type: 'send', message: 'include', arguments: {first: 'EmailSpec::Helpers'}
        expect(condition.matching_nodes([node])).to eq [node]
      end

      it 'gets empty array if does not match' do
        source = """
          RSpec.configure do |config|
            config.include EmailSpec::Helpers
            config.include EmailSpec::Methods
          end
        """
        node = Parser::CurrentRuby.parse(source)

        condition = Rewriter::IfOnlyExistCondition.new type: 'send', message: 'include', arguments: {first: {to_s: 'EmailSpec::Helpers'} }
        expect(condition.matching_nodes([node])).to eq []
      end
    end
  end
end
