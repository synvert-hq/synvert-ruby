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

### Convert dynamic finders

From rails 4, dynamic finder methods (e.g.
`User.find_all_by_login('richard')`) is deprecated, we should use
`User.where(login: 'richrd')` instead.

```ruby
{% raw %}
Synvert::Rewriter.new "convert_dynamic_finders", "Convert dynamic finders" do
  within_files '**/*.rb' do
    with_node type: 'send', message: /find_all_by_(.*)/ do
      # node is current matching ast node
      # you can add any ruby code in the block
      # here we convert dynamic finder message to hash params, e.g.
      # login_and_email('login', 'email') to
      # login: 'login', email: 'email'
      #
      # node.source(self) is used to get original ruby source code
      # {{receiver}} gets the receiver of current ast node
      fields = node.message.to_s["find_all_by_".length..-1].split("_and_")
      hash_params = fields.length.times.map { |i|
        fields[i] + ": " + node.arguments[i].source(self)
      }.join(", ")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end
end
{% endraw %}
```

We can use this snippet to convert other dynamic finders, e.g.
`find_last_by_`, but we don't want to calculate the hash_params
in each instance, so let's use helper_method for reuse.

```ruby
{% raw %}
Synvert::Rewriter.new "convert_dynamic_finders", "Convert dynamic finders" do
  helper_method 'dynamic_finder_to_hash' do |prefix|
    fields = node.message.to_s[prefix.length..-1].split("_and_")
    fields.length.times.map { |i|
      fields[i] + ": " + node.arguments[i].source(self)
    }.join(", ")
  end

  within_files '**/*.rb' do
    with_node type: 'send', message: /find_all_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_all_by_")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end
  within_files '**/*.rb' do
    with_node type: 'send', message: /find_last_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_last_by_")
      replace_with "{{receiver}}.where(#{hash_params}).last"
    end
  end
end
{% endraw %}
```
