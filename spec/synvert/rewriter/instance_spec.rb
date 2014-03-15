require 'spec_helper'

module Synvert
  describe Rewriter::Instance do
    let(:instance) { Rewriter::Instance.new('file pattern') }

    describe '#insert' do
      it 'sets an action' do
        expect(Rewriter::InsertAction).to receive(:new).with('{{arguments.first}}.include FactoryGirl::Syntax::Methods')
        instance.insert "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
      end
    end

    describe '#insert_after' do
      it 'sets an action' do
        expect(Rewriter::InsertAfterAction).to receive(:new).with('{{arguments.first}}.include FactoryGirl::Syntax::Methods')
        instance.insert_after "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
      end
    end

    describe '#replace_with' do
      it 'sets an action' do
        expect(Rewriter::ReplaceWithAction).to receive(:new).with('create {{arguments}}')
        instance.replace_with 'create {{arguments}}'
      end
    end

    describe '#remove' do
      it 'sets an action' do
        expect(Rewriter::RemoveAction).to receive(:new)
        instance.remove
      end
    end

    describe '#process' do
      before { Configuration.instance.set :path, '.' }

      it 'FactoryGirl uses short syntax' do
        instance = Rewriter::Instance.new 'spec/**/*_spec.rb' do
          with_node type: 'send', receiver: 'FactoryGirl', message: 'create' do
            replace_with 'create {{arguments}}'
          end
        end
        input = """
it 'uses factory_girl' do
  user = FactoryGirl.create :user
  post = FactoryGirl.create :post, user: user
  assert post.valid?
end
"""
        output = """
it 'uses factory_girl' do
  user = create :user
  post = create :post, user: user
  assert post.valid?
end
"""
        expect(Dir).to receive(:glob).with('./spec/**/*_spec.rb').and_return(['spec/models/post_spec.rb'])
        expect(File).to receive(:read).with('spec/models/post_spec.rb').and_return(input)
        expect(File).to receive(:write).with('spec/models/post_spec.rb', output)
        instance.process
      end

      it 'includes FactoryGirl::Syntax::Methods' do
        instance = Rewriter::Instance.new 'spec/spec_helper.rb'  do
          with_node type: 'block', caller: {receiver: 'RSpec', message: 'configure'} do
            unless_exist_node type: 'send', message: 'include', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'}} do
              insert "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
            end
          end
        end
        input = """
        RSpec.configure do |config|
        end
        """
        output = """
        RSpec.configure do |config|
          config.include FactoryGirl::Syntax::Methods
        end
        """
        expect(Dir).to receive(:glob).with('./spec/spec_helper.rb').and_return(['spec/spec_helper.rb'])
        expect(File).to receive(:read).with('spec/spec_helper.rb').and_return(input)
        expect(File).to receive(:write).with('spec/spec_helper.rb', output)
        instance.process
      end

      it 'does not include FactoryGirl::Syntax::Methods' do
        instance = Rewriter::Instance.new 'spec/spec_helper.rb' do
          with_node type: 'block', caller: {receiver: 'RSpec', message: 'configure'} do
            unless_exist_node type: 'send', message: 'include', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'}} do
              insert "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
            end
          end
        end
        input = """
        RSpec.configure do |config|
          config.include FactoryGirl::Syntax::Methods
        end
        """
        output = """
        RSpec.configure do |config|
          config.include FactoryGirl::Syntax::Methods
        end
        """
        expect(Dir).to receive(:glob).with('./spec/spec_helper.rb').and_return(['spec/spec_helper.rb'])
        expect(File).to receive(:read).with('spec/spec_helper.rb').and_return(input)
        expect(File).to receive(:write).with('spec/spec_helper.rb', output)
        instance.process
      end

      it 'process nested send nodes' do
        instance = Rewriter::Instance.new 'config/*.rb'  do
          with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'identity_map=' do
            remove
          end
        end
        input = 'config.active_record.identity_map = true'
        output = ''
        expect(Dir).to receive(:glob).with('./config/*.rb').and_return(['config/environments/production.rb'])
        expect(File).to receive(:read).with('config/environments/production.rb').and_return(input)
        expect(File).to receive(:write).with('config/environments/production.rb', output)
        instance.process
      end
    end
  end
end
