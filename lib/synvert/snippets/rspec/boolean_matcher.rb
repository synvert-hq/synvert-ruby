Synvert::Rewriter.new "convert_rspec_boolean_matcher" do
  description <<-EOF
It converts rspec boolean matcher.

    be_true => be_truthy
    be_false => be_falsey
  EOF

  if_gem 'rspec', {gte: '2.99.0'}

  within_files 'spec/**/*_spec.rb' do
    # be_true => be_truthy
    # be_false => be_falsey
    {be_true: 'be_truthy', be_false: 'be_falsey'}.each do |old_matcher, new_matcher|
      with_node type: 'send', receiver: nil, message: old_matcher do
        replace_with new_matcher
      end
    end
  end
end
