Synvert::Rewriter.new "convert_rspec_should_to_expect", "RSpec converts should to expect" do
  if_gem 'rspec', {gte: '2.11.0'}

  {should: 'to', should_not: 'not_to'}.each do |old_message, new_message|
    within_files 'spec/**/*.rb' do
      # obj.should matcher => expect(obj).to matcher
      # obj.should_not matcher => expect(obj).not_to matcher
      with_node type: 'send', receiver: {type: {not: 'block'}}, message: old_message do
        if node.receiver && node.arguments.size > 0
          replace_with "expect({{receiver}}).#{new_message} {{arguments}}"
        end
      end
    end

    {'==' => 'eq', '<' => 'be <', '>' => 'be >', '<=' => 'be <=', '>=' => 'be >=', '===' => 'be ==='}.each do |old_matcher, new_matcher|
      within_files 'spec/**/*.rb' do
        # 1.should == 1 => expect(1).to eq 1
        # 1.should < 1 => expect(1).to be < 2
        # Integer.should === 1 => expect(Integer).to be === 1
        with_node type: 'send', receiver: {type: 'send', message: old_message}, message: old_matcher do
          if node.receiver.receiver
            replace_with "expect({{receiver.receiver}}).#{new_message} #{new_matcher} {{arguments}}"
          end
        end
      end
    end

    within_files 'spec/**/*.rb' do
      # 'string'.should =~ /^str/ => expect('string').to match /^str/
      # [1, 2, 3].should =~ [2, 1, 3] => expect([1, 2, 3]).to match_array [2, 1, 3]
      with_node type: 'send', receiver: {type: 'send', message: old_message}, message: '=~' do
        if :regexp == node.arguments.first.type
          replace_with "expect({{receiver.receiver}}).#{new_message} match {{arguments}}"
        else
          replace_with "expect({{receiver.receiver}}).#{new_message} match_array {{arguments}}"
        end
      end
    end
  end
end
