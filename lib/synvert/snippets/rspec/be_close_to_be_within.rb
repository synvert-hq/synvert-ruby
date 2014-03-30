Synvert::Rewriter.new "convert_rspec_be_close_to_be_within", "RSpec converts be_close to be_within" do
  if_gem 'rspec', {gte: '2.1.0'}

  within_files 'spec/**/*.rb' do
    # expect(1.0 / 3.0).to be_close(0.333, 0.001) => expect(1.0 / 3.0).to be_within(0.001).of(0.333)
    with_node type: 'send', message: 'to', arguments: {first: {type: 'send', message: 'be_close'}} do
      within_arg = node.arguments.first.arguments.last.source(self)
      of_arg = node.arguments.first.arguments.first.source(self)
      replace_with "{{receiver}}.to be_within(#{within_arg}).of(#{of_arg})"
    end
  end
end
