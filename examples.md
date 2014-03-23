---
layout: page
title: Examples
---

I learn best by examples

### FactoryGirl short syntax method

Adds `include FactoryGirl::Syntax::Methods` to class
`Test::Unit::TestCase` in file `test/test_helper.rb`

```ruby
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  within_file 'test/test_helper.rb' do
    with_node type: 'class', name: 'Test::Unit::TestCase' do
      insert 'include FactoryGirl::Syntax::Methods'
    end
  end
end
```

FactoryGirl short syntax only works from factory_girl 2.0.0, so let's
check the gem version.

```ruby
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'test/test_helper.rb' do
    with_node type: 'class', name: 'Test::Unit::TestCase' do
      insert 'include FactoryGirl::Syntax::Methods'
    end
  end
end
```

It works, but it inserts code every time even `include
FactoryGirl::Syntax::Methods` already exist in the class, so let's check
if code doesn't exist, then insert.

```ruby
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'test/test_helper.rb' do
    with_node type: 'class', name: 'Test::Unit::TestCase' do
      unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
        insert 'include FactoryGirl::Syntax::Methods'
      end
    end
  end
end
```

It should also work in minitest and activesupport testcase

```ruby
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'test/test_helper.rb' do
    %w(Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase
        MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase).each do |class_name|
      with_node type: 'class', name: class_name do
        unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
          insert 'include FactoryGirl::Syntax::Methods'
        end
      end
    end
  end
end
```

For rspec, it does a bit different

```ruby
{% raw %}
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'spec/spec_helper.rb' do
    within_node type: 'block', caller: {receiver: 'RSpec', message: 'configure'} do
      # match code RSpec.configure do |config|; ... end
      unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
        # {{ }} is executed on current node, so we can add or replace with some old code,
        # arguments are [config], arguments.first is config,
        # here we insert `config.include FactoryGirl::Syntax::Methods`
        insert "{{arguments.first}}.include FactoryGirl::Syntax::Methods"
      end
    end
  end
end
{% endraw %}
```

Finally, apply it for cucumber as well.

```ruby
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  within_file 'features/support/env.rb' do
    # current node is the root node of env.rb file
    # we don't need with_node / within_node here
    unless_exist_node type: 'send', message: 'World', arguments: ['FactoryGirl::Syntax::Methods'] do
      insert "World(FactoryGirl::Syntax::Methods)"
    end
  end
end
```

We already insert `FactoryGirl::Syntax::Methods` module, then we can
replace `FactoryGirl.create` with `create` now.

```ruby
{% raw %}
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  %w(test/**/*.rb spec/**/*.rb features/**/*.rb).each do |file_pattern|
    # find all files in test/, spec/ and features/
    within_files file_pattern do
      with_node type: 'send', receiver: 'FactoryGirl', message: 'create' do
        # for FactoryGirl.create(:post, title: 'post'),
        # arguments are `:post, title: 'post'
        replace_with "create({{arguments}})"
      end
    end
  end
end
{% endraw %}
```

There are more short syntax, e.g. `build`, `create_list`, `build_list`, etc.

```ruby
{% raw %}
Synvert::Rewriter.new 'factory_girl_short_syntax', 'FactoryGirl uses short syntax' do
  gem_spec 'factory_girl', '2.0.0'

  %w(test/**/*.rb spec/**/*.rb features/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      %w(create build attributes_for build_stubbed create_list build_list
          create_pair build_pair).each do |message|
        with_node type: 'send', receiver: 'FactoryGirl', message: message do
          replace_with "#{message}({{arguments}})"
        end
      end
    end
  end
end
{% endraw %}
```
