Synvert::Rewriter.new "FactoryGirl uses short syntax" do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'spec/spec_helper.rb' do
    within_node type: 'block', caller: {receiver: 'RSpec', message: 'configure'} do
      unless_exist_node type: 'send', message: 'include', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'}} do
        insert "{{self.arguments.first}}.include FactoryGirl::Syntax::Methods"
      end
    end
  end

  %w(Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase).each do |class_name|
    within_file 'test/test_helper.rb' do
      within_node type: 'class', name: class_name do
        unless_exist_node type: 'send', message: 'include', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'}} do
          insert "include FactoryGirl::Syntax::Methods"
        end
      end
    end
  end

  within_file 'features/support/env.rb' do
    unless_exist_node type: 'send', message: 'World', arguments: {first: {to_s: 'FactoryGirl::Syntax::Methods'}} do
      insert "World(FactoryGirl::Syntax::Methods)"
    end
  end

  %w(test/**/*.rb spec/**/*.rb features/**/*.rb).each do |file_pattern|
    %w(create build attributes_for build_stubbed create_list build_list ccreate_pair build_pair).each do |message|
      within_files file_pattern do
        with_node type: 'send', receiver: 'FactoryGirl', message: message do
          replace_with "#{message}({{self.arguments}})"
        end
      end
    end
  end
end
