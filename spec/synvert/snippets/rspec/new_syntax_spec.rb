require 'spec_helper'

describe 'Use RSpec new syntax' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
    Dir.glob File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/rspec/*') do |file|
      if file =~ /new_syntax.rb$/
        @rewriter = eval(File.read(file))
      else
        eval(File.read(file))
      end
    end
  end

  describe 'rspec', fakefs: true do
    let(:post_spec_content) {"""
it 'case' do
  obj.should matcher
  obj.should_not matcher

  1.should == 1
  1.should < 2
  Integer.should === 1
  'string'.should =~ /^str/
  [1, 2, 3].should =~ [2, 1, 3]

  expect(obj).to be_true
  expect(obj).to be_false

  expect(1.0 / 3.0).to be_close(0.333, 0.001)

  expect(collection).to have(3).items
  expect(collection).to have_exactly(3).items
  expect(collection).to have_at_least(3).items
  expect(collection).to have_at_most(3).items

  expect(team).to have(3).players

  lambda { do_something }.should raise_error
  proc { do_something }.should raise_error
  -> { do_something }.should raise_error

  expect { do_something }.not_to raise_error(SomeErrorClass)
  expect { do_something }.not_to raise_error('message')
  expect { do_something }.not_to raise_error(SomeErrorClass, 'message')

  obj.should_receive(:message)
  Klass.any_instance.should_receive(:message)

  obj.stub(:message)
  obj.stub!(:message)
  obj.stub_chain(:foo, :bar, :baz)
  Klass.any_instance.stub(:message)

  obj.stub(:foo => 1, :bar => 2)

  obj.unstub!(:message)

  obj.stub(:message).any_number_of_times
  obj.stub(:message).at_least(0)

  expect(obj).to receive(:message).and_return { 1 }
  allow(obj).to receive(:message).and_return { 1 }

  expect(obj).to receive(:message).and_return
  allow(obj).to receive(:message).and_return

  stub('something')
  mock('something')
end

it { should matcher }
it { should_not matcher }

it { should have(3).items }
it { should have_at_least(3).players }

describe 'example' do
  subject { { foo: 1, bar: 2 } }
  its(:size) { should == 2 }
  its([:foo]) { should == 1 }
  its('keys.first') { should == :foo }
end
    """}
    let(:post_spec_rewritten_content) {"""
it 'case' do
  expect(obj).to matcher
  expect(obj).not_to matcher

  expect(1).to eq 1
  expect(1).to be < 2
  expect(Integer).to be === 1
  expect('string').to match /^str/
  expect([1, 2, 3]).to match_array [2, 1, 3]

  expect(obj).to be_truthy
  expect(obj).to be_falsey

  expect(1.0 / 3.0).to be_within(0.001).of(0.333)

  expect(collection.size).to eq 3
  expect(collection.size).to eq 3
  expect(collection.size).to be >= 3
  expect(collection.size).to be <= 3

  expect(team.players.size).to eq 3

  expect { do_something }.to raise_error
  expect { do_something }.to raise_error
  expect { do_something }.to raise_error

  expect { do_something }.not_to raise_error
  expect { do_something }.not_to raise_error
  expect { do_something }.not_to raise_error

  expect(obj).to receive(:message)
  expect_any_instance_of(Klass).to receive(:message)

  allow(obj).to receive(:message)
  allow(obj).to receive(:message)
  allow(obj).to receive_message_chain(:foo, :bar, :baz)
  allow_any_instance_of(Klass).to receive(:message)

  allow(obj).to receive_messages(:foo => 1, :bar => 2)

  obj.unstub(:message)

  allow(obj).to receive(:message)
  allow(obj).to receive(:message)

  expect(obj).to receive(:message) { 1 }
  allow(obj).to receive(:message) { 1 }

  expect(obj).to receive(:message)
  allow(obj).to receive(:message)

  double('something')
  double('something')
end

it { is_expected.to matcher }
it { is_expected.not_to matcher }

it 'has 3 items' do
  expect(subject.size).to eq(3)
end

it 'has at least 3 players' do
  expect(subject.players.size).to be >= 3
end

describe 'example' do
  subject { { foo: 1, bar: 2 } }

  describe '#size' do
    subject { super().size }
    it { should == 2 }
  end

  describe '[:foo]' do
    subject { super()[:foo] }
    it { should == 1 }
  end

  describe '#keys' do
    subject { super().keys }
    describe '#first' do
      subject { super().first }
      it { should == :foo }
    end
  end
end
    """}

    it 'process' do
      FileUtils.mkdir_p 'spec/models'
      File.write 'spec/models/post_spec.rb', post_spec_content
      @rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
    end
  end
end
