require 'spec_helper'

describe 'FactoryGirl uses short synax' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    rewriter_path = File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/factory_girl/syntax_methods.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'rspec', fakefs: true do
    let(:spec_helper_content) {'''
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
end
    '''}
    let(:spec_helper_rewritten_content) {'''
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
end
    '''}
    let(:post_spec_content) {'''
describe Post do
  it "tests post" do
    post1 = FactoryGirl.create(:post)
    post2 = FactoryGirl.build(:post)
    post_attributes = FactoryGirl.attributes_for(:post)
    post3 = FactoryGirl.build_stubbed(:post)
    posts1 = FactoryGirl.create_list(:post, 2)
    posts2 = FactoryGirl.build_list(:post, 2)
    posts3 = FactoryGirl.create_pair(:post)
    posts4 = FactoryGirl.build_pair(:post)
  end
end
    '''}
    let(:post_spec_rewritten_content) {'''
describe Post do
  it "tests post" do
    post1 = create(:post)
    post2 = build(:post)
    post_attributes = attributes_for(:post)
    post3 = build_stubbed(:post)
    posts1 = create_list(:post, 2)
    posts2 = build_list(:post, 2)
    posts3 = create_pair(:post)
    posts4 = build_pair(:post)
  end
end
    '''}

    it 'process' do
      allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
      FileUtils.mkdir 'spec'
      FileUtils.mkdir 'spec/models'
      File.write 'spec/spec_helper.rb', spec_helper_content
      File.write 'spec/models/post_spec.rb', post_spec_content
      @rewriter.process
      expect(File.read 'spec/spec_helper.rb').to eq spec_helper_rewritten_content
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
    end
  end

  describe 'test/unit', fakefs: true do
    let(:test_helper_content) {'''
class ActiveSupport::TestCase
end
    '''}
    let(:test_helper_rewritten_content) {'''
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end
    '''}
    let(:post_test_content) {'''
test "post" do
  post1 = FactoryGirl.create(:post)
  post2 = FactoryGirl.build(:post)
  post_attributes = FactoryGirl.attributes_for(:post)
  post3 = FactoryGirl.build_stubbed(:post)
  posts1 = FactoryGirl.create_list(:post, 2)
  posts2 = FactoryGirl.build_list(:post, 2)
  posts3 = FactoryGirl.create_pair(:post)
  posts4 = FactoryGirl.build_pair(:post)
end
    '''}
    let(:post_test_rewritten_content) {'''
test "post" do
  post1 = create(:post)
  post2 = build(:post)
  post_attributes = attributes_for(:post)
  post3 = build_stubbed(:post)
  posts1 = create_list(:post, 2)
  posts2 = build_list(:post, 2)
  posts3 = create_pair(:post)
  posts4 = build_pair(:post)
end
    '''}

    it 'process' do
      allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
      FileUtils.mkdir 'test'
      FileUtils.mkdir 'test/unit'
      File.write 'test/test_helper.rb', test_helper_content
      File.write 'test/unit/post_test.rb', post_test_content
      @rewriter.process
      expect(File.read 'test/test_helper.rb').to eq test_helper_rewritten_content
      expect(File.read 'test/unit/post_test.rb').to eq post_test_rewritten_content
    end
  end

  describe 'cucumber', fakefs: true do
    let(:env_content) {'''
require "cucumber/rails"
    '''}
    let(:env_rewritten_content) {'''
require "cucumber/rails"
World(FactoryGirl::Syntax::Methods)
    '''}
    let(:post_steps_content) {'''
test "post" do
  post1 = FactoryGirl.create(:post)
  post2 = FactoryGirl.build(:post)
  post_attributes = FactoryGirl.attributes_for(:post)
  post3 = FactoryGirl.build_stubbed(:post)
  posts1 = FactoryGirl.create_list(:post, 2)
  posts2 = FactoryGirl.build_list(:post, 2)
  posts3 = FactoryGirl.create_pair(:post)
  posts4 = FactoryGirl.build_pair(:post)
end
    '''}
    let(:post_steps_rewritten_content) {'''
test "post" do
  post1 = create(:post)
  post2 = build(:post)
  post_attributes = attributes_for(:post)
  post3 = build_stubbed(:post)
  posts1 = create_list(:post, 2)
  posts2 = build_list(:post, 2)
  posts3 = create_pair(:post)
  posts4 = build_pair(:post)
end
    '''}

    it 'process' do
      allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
      FileUtils.mkdir_p 'features/support'
      FileUtils.mkdir_p 'features/step_definitions'
      File.write 'features/support/env.rb', env_content
      File.write 'features/step_definitions/post_steps.rb', post_steps_content
      @rewriter.process
      expect(File.read 'features/support/env.rb').to eq env_rewritten_content
      expect(File.read 'features/step_definitions/post_steps.rb').to eq post_steps_rewritten_content
    end
  end
end
