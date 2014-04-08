Synvert::Rewriter.new "convert_rspec_message_expectation" do
  description <<-EOF
It convert rspec message expectation.

    obj.should_receive(:message) => expect(obj).to receive(:message)
    Klass.any_instance.should_receive(:message) => expect_any_instance_of(Klass).to receive(:message)

    expect(obj).to receive(:message).and_return { 1 } => expect(obj).to receive(:message) { 1 }

    expect(obj).to receive(:message).and_return { 1 } => expect(obj).to receive(:message) { 1 }

    expect(obj).to receive(:message).and_return => expect(obj).to receive(:message)
  EOF

  if_gem 'rspec', {gte: '2.14.0'}

  within_files 'spec/**/*.rb' do
    # obj.should_receive(:message) => expect(obj).to receive(:message)
    # Klass.any_instance.should_receive(:message) => expect_any_instance_of(Klass).to receive(:message)
    with_node type: 'send', message: 'should_receive' do
      if_exist_node type: 'send', message: 'any_instance' do
        replace_with "expect_any_instance_of({{receiver.receiver}}).to receive({{arguments}})"
      end
      unless_exist_node type: 'send', message: 'any_instance' do
        replace_with "expect({{receiver}}).to receive({{arguments}})"
      end
    end
  end

  within_files 'spec/**/*.rb' do
    # expect(obj).to receive(:message).and_return { 1 } => expect(obj).to receive(:message) { 1 }
    with_node type: 'send', receiver: {type: 'send', message: 'expect'}, arguments: {first: {type: 'block', caller: {type: 'send', message: 'and_return', arguments: []}}} do
      replace_with "{{receiver}}.to {{arguments.first.caller.receiver}} { {{arguments.first.body}} }"
    end

    # expect(obj).to receive(:message).and_return => expect(obj).to receive(:message)
    with_node type: 'send', receiver: {type: 'send', message: 'expect'}, arguments: {first: {type: 'send', message: 'and_return', arguments: []}} do
      replace_with "{{receiver}}.to {{arguments.first.receiver}}"
    end
  end
end
