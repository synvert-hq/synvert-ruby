Synvert::Rewriter.new "convert_rspec_one_liner_expectation", "RSpec converts one liner expectation" do
  gem_spec 'rspec', '2.99.0'

  {should: 'to', should_not: 'not_to'}.each do |old_message, new_message|
    matcher_converters = {have: 'eq', have_exactly: 'eq', have_at_least: 'be >=', have_at_most: 'be <='}
    matcher_converters.each do |old_matcher, new_matcher|
      within_files 'spec/**/*.rb' do
        # it { should have(3).items }
        # =>
        # it 'has 3 items' do
        #   expect(subject.size).to eq(3)
        # end
        #
        # it { should have_at_least(3).players }
        # =>
        # it 'has at least 3 players' do
        #   expect(subject.players.size).to be >= 3
        # end
        with_node type: 'block', caller: {message: 'it'} do
          if_only_exist_node type: 'send', receiver: nil, message: old_message, arguments: {first: {type: 'send', receiver: {type: 'send', message: old_matcher}}} do
            times = node.body.first.arguments.first.receiver.arguments.first.source(self)
            items_name = node.body.first.arguments.first.message
            if :items == items_name
              replace_with """it 'has #{times} items' do
  expect(subject.size).#{new_message} #{new_matcher}(#{times})
end"""
            else
              it_message = "#{old_matcher.to_s.sub('have', 'has').gsub('_', ' ')} #{times} #{items_name}"
              replace_with """it '#{it_message}' do
  expect(subject.#{items_name}.size).#{new_message} #{new_matcher} #{times}
end"""
            end
          end
        end
      end
    end
  end

  {should: 'to', should_not: 'not_to'}.each do |old_message, new_message|
    within_files 'spec/**/*.rb' do
      # it { should matcher } => it { is_expected.to matcher }
      # it { should_not matcher } => it { is_expected.not_to matcher }
      with_node type: 'block', caller: {message: 'it'} do
        if_only_exist_node type: 'send', receiver: nil, message: old_message do
          matcher = node.body.first.arguments.first.source(self)
          replace_with "it { is_expected.#{new_message} #{matcher} }"
        end
      end
    end
  end
end
