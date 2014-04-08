Synvert::Rewriter.new "convert_rspec_block_to_expect" do
  description <<-EOF
It converts rspec block to expect.

    lambda { do_something }.should raise_error => expect { do_something }.to raise_error
    proc { do_something }.should raise_error => expect { do_something }.to raise_error
    -> { do_something }.should raise_error => expect { do_something }.to raise_error
  EOF

  if_gem 'rspec', {gte: '2.11.0'}

  within_files 'spec/**/*.rb' do
    # lambda { do_something }.should raise_error => expect { do_something }.to raise_error
    # proc { do_something }.should raise_error => expect { do_something }.to raise_error
    # -> { do_something }.should raise_error => expect { do_something }.to raise_error
    {should: 'to', should_not: 'not_to'}.each do |old_message, new_message|
      with_node type: 'send', receiver: {type: 'block'}, message: old_message do
        replace_with "expect { {{receiver.body}} }.#{new_message} {{arguments}}"
      end
    end
  end
end
