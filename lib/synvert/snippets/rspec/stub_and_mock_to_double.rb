Synvert::Rewriter.new "convert_rspec_stub_and_mock_to_double", "RSpec converts stub and mock to double" do
  if_gem 'rspec', {gte: '2.14.0'}

  within_files 'spec/**/*.rb' do
    # stub('something') => double('something')
    # mock('something') => double('something')
    with_node type: 'send', receiver: nil, message: 'stub' do
      replace_with "double({{arguments}})"
    end

    with_node type: 'send', receiver: nil, message: 'mock' do
      replace_with "double({{arguments}})"
    end
  end
end
