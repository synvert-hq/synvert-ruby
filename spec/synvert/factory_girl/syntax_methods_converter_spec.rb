# coding: utf-8
require 'spec_helper'

describe Synvert::FactoryGirl::SyntaxMethodsConverter do
  describe "#interesting_files" do
    ["spec/spec_helper.rb", "test/test_helper.rb", "features/support/env.rb",
    "spec/support/shared_context.rb", "test/support/shared_context.rb",
    "spec/models/post_spec.rb", "test/unit/post_test.rb", "features/step_definitions/post_steps.rb"].each do |file_path|
      context file_path do
        let(:filename) { file_path }
        include_context "interesting file"
      end
    end

    context "app/models/post.rb" do
      let(:filename) { "app/models/post.rb" }
      include_context "not interesting file"
    end
  end

  context "spec_helper.rb" do
    let(:filename) { "spec/spec_helper.rb" }
    let(:source) {
      <<-EOF
      RSpec.configure do |config|
        config.include EmailSpec::Helpers
      end
      EOF
    }
    let(:expected_source) {
      <<-EOF
      RSpec.configure do |config|
        config.include EmailSpec::Helpers
        config.include FactoryGirl::Syntax::Methods
      end
      EOF
    }
    include_context "expect to convert"
  end

  context "test_helper.rb" do
    context "Test::Unit::TestCase" do
      let(:filename) { "test/test_helper.rb" }
      let(:source) {
        <<-EOF
        class Test::Unit::TestCase
        end
        EOF
      }
      let(:expected_source) {
        <<-EOF
        class Test::Unit::TestCase
          include FactoryGirl::Syntax::Methods
        end
        EOF
      }
      include_context "expect to convert"
    end

    context "ActiveSupport::TestCase" do
      let(:filename) { "test/test_helper.rb" }
      let(:source) {
        <<-EOF
        class ActiveSupport::TestCase
          include EmailSpec::Helpers
        end
        EOF
      }
      let(:expected_source) {
        <<-EOF
        class ActiveSupport::TestCase
          include EmailSpec::Helpers
          include FactoryGirl::Syntax::Methods
        end
        EOF
      }
      include_context "expect to convert"
    end
  end

  context "features/support/env.rb" do
    let(:filename) { "features/support/env.rb" }
    let(:source) {
      <<-EOF
      require 'cucumber/rails'
      EOF
    }
    let(:expected_source) {
      <<-EOF
      require 'cucumber/rails'
      World(FactoryGirl::Syntax::Methods)
      EOF
    }
    include_context "expect to convert"
  end

  [:create, :build, :attributes_for, :build_stubbed].each do |method|
    class_eval do
      context "FactoryGirl.#{method}" do
        let(:filename) { "spec/models/post_spec.rb" }
        let(:source) {
          <<-EOF
          it "valids post" do
            post = FactoryGirl.#{method}(:post)
            expect(post).to be_valid
          end
          EOF
        }
        let(:expected_source) {
          <<-EOF
          it "valids post" do
            post = #{method}(:post)
            expect(post).to be_valid
          end
          EOF
        }

        include_context "expect to convert"
      end
    end
  end

  [:create_list, :build_list, :create_pair, :build_pair].each do |method|
    class_eval do
      context "FactoryGirl.#{method}" do
        let(:filename) { "spec/models/post_spec.rb" }
        let(:source) {
          <<-EOF
          it "valids posts" do
            posts = FactoryGirl.#{method}(:post)
            expect(posts).to be_valid
          end
          EOF
        }
        let(:expected_source) {
          <<-EOF
          it "valids posts" do
            posts = #{method}(:post)
            expect(posts).to be_valid
          end
          EOF
        }

        include_context "expect to convert"
      end
    end
  end
end
