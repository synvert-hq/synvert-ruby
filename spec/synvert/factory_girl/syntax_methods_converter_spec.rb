# coding: utf-8
require 'spec_helper'

describe Synvert::FactoryGirl::SyntaxMethodsConverter do
  describe "#interesting_files" do
    context "spec/spec_helper.rb" do
      let(:filename) { "spec/spec_helper.rb" }
      include_context "interesting file"
    end

    context "test/test_helper.rb" do
      let(:filename) { "test/test_helper.rb" }
      include_context "interesting file"
    end

    context "features/support/env.rb" do
      let(:filename) { "features/support/env.rb" }
      include_context "interesting file"
    end

    context "spec/support/shared_context.rb" do
      let(:filename) { "spec/support/shared_context.rb" }
      include_context "interesting file"
    end

    context "test/support/shared_context.rb" do
      let(:filename) { "test/support/shared_context.rb" }
      include_context "interesting file"
    end

    context "spec/models/post_spec.rb" do
      let(:filename) { "spec/models/post_spec.rb" }
      include_context "interesting file"
    end

    context "test/unit/post_test.rb" do
      let(:filename) { "test/unit/post_test.rb" }
      include_context "interesting file"
    end

    context "features/step_definitions/post_steps.rb" do
      let(:filename) { "features/step_definitions/post_steps.rb" }
      include_context "interesting file"
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
        config.include FactoryGirl::Syntax::Methods
        config.include EmailSpec::Helpers
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
          include FactoryGirl::Syntax::Methods
          include EmailSpec::Helpers
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

  context "FactoryGirl.create" do
    let(:filename) { "spec/models/post_spec.rb" }
    let(:source) {
      <<-EOF
      it "valids post" do
        post = FactoryGirl.create(:post)
        expect(post).to be_valid
      end
      EOF
    }
    let(:expected_source) {
      <<-EOF
      it "valids post" do
        post = create(:post)
        expect(post).to be_valid
      end
      EOF
    }

    include_context "expect to convert"
  end

  context "FactoryGirl.build" do
    let(:filename) { "spec/models/post_spec.rb" }
    let(:source) {
      <<-EOF
      it "valids post" do
        post = FactoryGirl.build(:post)
        expect(post).to be_valid
      end
      EOF
    }
    let(:expected_source) {
      <<-EOF
      it "valids post" do
        post = build(:post)
        expect(post).to be_valid
      end
      EOF
    }

    include_context "expect to convert"
  end

  context "FactoryGirl.attributes_for" do
    let(:filename) { "spec/models/post_spec.rb" }
    let(:source) {
      <<-EOF
      it "valids post" do
        post = FactoryGirl.attributes_for(:post)
        expect(post).to be_valid
      end
      EOF
    }
    let(:expected_source) {
      <<-EOF
      it "valids post" do
        post = attributes_for(:post)
        expect(post).to be_valid
      end
      EOF
    }

    include_context "expect to convert"
  end

  context "FactoryGirl.build_stubbed" do
    let(:filename) { "spec/models/post_spec.rb" }
    let(:source) {
      <<-EOF
      it "valids post" do
        post = FactoryGirl.build_stubbed(:post)
        expect(post).to be_valid
      end
      EOF
    }
    let(:expected_source) {
      <<-EOF
      it "valids post" do
        post = build_stubbed(:post)
        expect(post).to be_valid
      end
      EOF
    }

    include_context "expect to convert"
  end
end
