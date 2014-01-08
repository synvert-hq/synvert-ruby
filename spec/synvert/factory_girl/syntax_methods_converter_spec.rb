# coding: utf-8
require 'spec_helper'

describe Synvert::FactoryGirl::SyntaxMethodsConverter do
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
