Synvert::Rewriter.new "convert_rspec_method_stub" do
  description <<-EOF
It converts rspec method stub.

    obj.stub!(:message) => obj.stub(:message)
    obj.unstub!(:message) => obj.unstub(:message)

    obj.stub(:message).any_number_of_times => allow(obj).to receive(:message)
    obj.stub(:message).at_least(0) => allow(obj).to receive(:message)

    obj.stub(:message) => allow(obj).to receive(:message)
    Klass.any_instance.stub(:message) => allow_any_instance_of(Klass).to receive(:message)

    obj.stub_chain(:foo, :bar, :baz) => allow(obj).to receive_message_chain(:foo, :bar, :baz)

    obj.stub(:foo => 1, :bar => 2) => allow(obj).to receive_messages(:foo => 1, :bar => 2)

    allow(obj).to receive(:message).and_return { 1 } => allow(obj).to receive(:message) { 1 }

    allow(obj).to receive(:message).and_return => allow(obj).to receive(:message)
  EOF

  if_gem 'rspec', {gte: '2.14.0'}

  within_files 'spec/**/*.rb' do
    # obj.stub!(:message) => obj.stub(:message)
    # obj.unstub!(:message) => obj.unstub(:message)
    {stub!: 'stub', unstub!: 'unstub'}.each do |old_message, new_message|
      with_node type: 'send', message: old_message do
        replace_with "{{receiver}}.#{new_message}({{arguments}})"
      end
    end

    # obj.stub(:message).any_number_of_times => allow(obj).to receive(:message)
    # obj.stub(:message).at_least(0) => allow(obj).to receive(:message)
    with_node type: 'send', message: 'any_number_of_times' do
      replace_with "{{receiver}}"
    end

    with_node type: 'send', message: 'at_least', arguments: [0] do
      replace_with "{{receiver}}"
    end

    # obj.stub(:message) => allow(obj).to receive(:message)
    # Klass.any_instance.stub(:message) => allow_any_instance_of(Klass).to receive(:message)
    with_node type: 'send', message: 'stub', arguments: {first: {type: {not: 'hash'}}} do
      if_exist_node type: 'send', message: 'any_instance' do
        replace_with "allow_any_instance_of({{receiver.receiver}}).to receive({{arguments}})"
      end
      unless_exist_node type: 'send', message: 'any_instance' do
        replace_with "allow({{receiver}}).to receive({{arguments}})"
      end
    end
  end

  if_gem 'rspec', {gte: '3.0.0'}

  within_files 'spec/**/*.rb' do
    # obj.stub_chain(:foo, :bar, :baz) => allow(obj).to receive_message_chain(:foo, :bar, :baz)
    with_node type: 'send', message: 'stub_chain' do
      if_exist_node type: 'send', message: 'any_instance' do
        replace_with "allow_any_instance_of({{receiver.receiver}}).to receive_message_chain({{arguments}})"
      end
      unless_exist_node type: 'send', message: 'any_instance' do
        replace_with "allow({{receiver}}).to receive_message_chain({{arguments}})"
      end
    end

    # obj.stub(:foo => 1, :bar => 2) => allow(obj).to receive_messages(:foo => 1, :bar => 2)
    with_node type: 'send', message: 'stub', arguments: {first: {type: 'hash'}} do
      replace_with "allow({{receiver}}).to receive_messages({{arguments}})"
    end

    # allow(obj).to receive(:message).and_return { 1 } => allow(obj).to receive(:message) { 1 }
    with_node type: 'send', receiver: {type: 'send', message: 'allow'}, arguments: {first: {type: 'block', caller: {type: 'send', message: 'and_return', arguments: []}}} do
      replace_with "{{receiver}}.to {{arguments.first.caller.receiver}} { {{arguments.first.body}} }"
    end

    # allow(obj).to receive(:message).and_return => allow(obj).to receive(:message)
    with_node type: 'send', receiver: {type: 'send', message: 'allow'}, arguments: {first: {type: 'send', message: 'and_return', arguments: []}} do
      replace_with "{{receiver}}.to {{arguments.first.receiver}}"
    end
  end
end
