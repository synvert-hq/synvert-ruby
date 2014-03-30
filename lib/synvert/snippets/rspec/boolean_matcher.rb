Synvert::Rewriter.new "convert_rspec_boolean_matcher", "RSpec converts boolean matcher" do
  if_gem 'rspec', {gte: '2.99.0'}

  {be_true: 'be_truthy', be_false: 'be_falsey'}.each do |old_matcher, new_matcher|
    within_files 'spec/**/*_spec.rb' do
      # be_true => be_truthy
      # be_false => be_falsey
      with_node type: 'send', receiver: nil, message: old_matcher do
        replace_with new_matcher
      end
    end
  end
end
