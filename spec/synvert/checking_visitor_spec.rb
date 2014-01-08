# coding: utf-8
require 'spec_helper'

module Synvert
  describe CheckingVisitor do
    subject { CheckingVisitor.new }

    context "initialize" do
      it "factory_girl syntax methods converter is one of default converts" do
        expect(subject.converters.first).is_a? FactoryGirl::SyntaxMethodsConverter
      end
    end

    context "#convert_file" do
      it "writes converted source" do
        File.expects(:read).with('test.rb').returns('source')
        subject.expects(:convert).with('test.rb', 'source').returns('converted source')
        File.expects(:write).with('test.rb', 'converted source')
        subject.convert_file 'test.rb'
      end

      it "doesn't write if converted source is same to source" do
        File.expects(:read).with('test.rb').returns('source')
        subject.expects(:convert).with('test.rb', 'source').returns('source')
        File.expects(:write).never
        subject.convert_file 'test.rb'
      end
    end

    context "#convert" do
      it "gets converted source" do
        subject.converters.first.stubs(:rewrite).returns("converted source")
        expect(subject.convert("spec/spec_helper.rb", "source")).to eq "converted source"
      end

      it "gets source if none of converter works" do
        subject.converters.first.stubs(:rewrite).returns("converted source")
        expect(subject.convert("(string)", "source")).to eq "source"
      end
    end
  end
end
