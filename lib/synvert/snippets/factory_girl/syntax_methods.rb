Synvert::Rewriter.new "factory_girl_short_syntax" do
  description <<-EOF
Uses FactoryGirl short syntax.

1. it adds FactoryGirl::Syntax::methods module to RSpec, Test::Unit, Cucumber, Spainach, MiniTest, MiniTest::Spec, minitest-rails.

    # rspec
    RSpec.configure do |config|
      config.include FactoryGirl::Syntax::Methods
    end

    # Test::Unit
    class Test::Unit::TestCase
      include FactoryGirl::Syntax::Methods
    end

    # Cucumber
    World(FactoryGirl::Syntax::Methods)

    # Spinach
    class Spinach::FeatureSteps
      include FactoryGirl::Syntax::Methods
    end

    # MiniTest
    class MiniTest::Unit::TestCase
      include FactoryGirl::Syntax::Methods
    end

    # MiniTest::Spec
    class MiniTest::Spec
      include FactoryGirl::Syntax::Methods
    end

    # minitest-rails
    class MiniTest::Rails::ActiveSupport::TestCase
      include FactoryGirl::Syntax::Methods
    end

2. it converts to short syntax.

    FactoryGirl.create(...) => create(...)
    FactoryGirl.build(...) => build(...)
    FactoryGirl.attributes_for(...) => attributes_for(...)
    FactoryGirl.build_stubbed(...) => build_stubbed(...)
    FactoryGirl.create_list(...) => create_list(...)
    FactoryGirl.build_list(...) => build_list(...)
    FactoryGirl.create_pair(...) => create_pair(...)
    FactoryGirl.build_pair(...) => build_pair(...)
  EOF

  if_gem 'factory_girl', {gte: '2.0.0'}

  # insert include FactoryGirl::Syntax::Methods
  within_file 'spec/spec_helper.rb' do
    within_node type: 'block', caller: {receiver: 'RSpec', message: 'configure'} do
      unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
        insert "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
      end
    end
  end

  # insert include FactoryGirl::Syntax::Methods
  within_file 'test/test_helper.rb' do
    %w(Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase).each do |class_name|
      within_node type: 'class', name: class_name do
        unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
          insert "include FactoryGirl::Syntax::Methods"
        end
      end
    end
  end

  # insert World(FactoryGirl::Syntax::Methods)
  within_file 'features/support/env.rb' do
    unless_exist_node type: 'send', message: 'World', arguments: ['FactoryGirl::Syntax::Methods'] do
      insert "World(FactoryGirl::Syntax::Methods)"
    end
  end

  # FactoryGirl.create(...) => create(...)
  # FactoryGirl.build(...) => build(...)
  # FactoryGirl.attributes_for(...) => attributes_for(...)
  # FactoryGirl.build_stubbed(...) => build_stubbed(...)
  # FactoryGirl.create_list(...) => create_list(...)
  # FactoryGirl.build_list(...) => build_list(...)
  # FactoryGirl.create_pair(...) => create_pair(...)
  # FactoryGirl.build_pair(...) => build_pair(...)
  %w(test/**/*.rb spec/**/*.rb features/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      %w(create build attributes_for build_stubbed create_list build_list create_pair build_pair).each do |message|
        with_node type: 'send', receiver: 'FactoryGirl', message: message do
          replace_with "#{message}({{arguments}})"
        end
      end
    end
  end
end
