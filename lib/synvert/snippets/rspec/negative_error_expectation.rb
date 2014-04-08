Synvert::Rewriter.new "convert_rspec_negative_error_expectation" do
  description <<-EOF
It converts rspec negative error expectation.

    expect { do_something }.not_to raise_error(SomeErrorClass) => expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error('message') => expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error(SomeErrorClass, 'message') => expect { do_something }.not_to raise_error
  EOF
  if_gem 'rspec', {gte: '2.14.0'}

  within_files 'spec/**/*.rb' do
    # expect { do_something }.not_to raise_error(SomeErrorClass) => expect { do_something }.not_to raise_error
    # expect { do_something }.not_to raise_error('message') => expect { do_something }.not_to raise_error
    # expect { do_something }.not_to raise_error(SomeErrorClass, 'message') => expect { do_something }.not_to raise_error
    within_node type: 'send', receiver: {type: 'block'}, message: 'not_to' do
      with_node type: 'send', message: 'raise_error' do
        replace_with "raise_error"
      end
    end
  end
end
