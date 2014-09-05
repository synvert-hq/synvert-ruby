---
layout: page
title: DSL
---

Synvert provides a simple dsl to define a snippet.

```ruby
Synvert::Rewriter.new "name" do
  description "description"

  if_gem gem_name, {gte: gem_version}

  within_file file_pattern do
    within_node rules do
      with_node rules do
        remove
      end
    end
  end

  within_files files_pattern do
    with_node rules do
      unless_exist_node rule do
        insert code
      end
    end
  end
end
```

### describe

Describe what the snippet does.

```ruby
description 'descriptin of snippet'
```

### if\_gem

Checks the gem in `Gemfile.lock`, if gem version in `Gemfile.lock`
is less than, greater than or equal to the version in `if_gem`,
the snippet will be executed, otherwise, the snippet will be ignored.

```ruby
if_gem 'factory_girl', {eq: '2.0.0'}
if_gem 'factory_girl', {ne: '2.0.0'}
if_gem 'factory_girl', {gt: '2.0.0'}
if_gem 'factory_girl', {lt: '2.0.0'}
if_gem 'factory_girl', {gte: '2.0.0'}
if_gem 'factory_girl', {lte: '2.0.0'}
```

### add\_file

Add a new file and write content.

```ruby
content =<<- EOF
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
EOF
add_file 'config/initializers/wrap_parameters.rb', content.strip
```

### remove\_file

Remove a file.

```ruby
remove_file 'config/initiliazers/secret_token.rb'
```

### within\_file / within\_files

Find files according to file pattern, the block will be executed
only for the matching files.

```ruby
within_file 'spec/spec_helper.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

```ruby
within_files 'spec/**/*_spec.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

### with\_node / within\_node

Find ast nodes according to the [rules][1], the block will be executed
for the matching nodes.

```ruby
with_node type: 'send', 'receiver: 'FactoryGirl', message: 'create' do
  # check nodes
  # add / replace / remove code
end
```

```ruby
within_node type: 'class', name: 'Test::Unit::TestCase' do
  # find child nodes
  # check nodes
  # add / replace / remove code
end
```

### goto\_node

Go to the specified child code.

```ruby
with_node type: 'block' do
  goto_node :caller do
    # change code in block caller
  end
end
```

### if\_exist\_node

Check if the node matches [rules][1] exists, if matches, then executes
the block.

```ruby
if_exist_node type: 'send', receiver: 'params', message: '[]' do
  # add / replace / remove code
end
```

### unless\_exist\_node

Check if the node matches [rules][1] does not exist, if does not match,
then executes the block.

```ruby
unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
  # add / replace / remove code
end
```

### if\_noly\_exist\_node

Check if the current node contains only one child node and the child
node matches [rules][1], if matches, then executes the node.

```ruby
if_only_exist_node type: 'send', receiver: 'self', message: 'include_root_in_json=', arguments: [false] do
  # add / replace / remove code
end
```

### append

Add the code at the bottom of the current node body.

```ruby
append 'config.eager_load = false'
```

### insert

Add the code at the top of the current node body.

```ruby
insert "include FactoryGirl::Syntax::Methods"
```

### insert\_after

Add the code next to the current node.

```ruby
{% raw %}
secret = SecureRandom.hex(64)
insert_after "{{receiver}}.secret_key_base = '#{secret}'"
{% endraw %}
```

### replace\_with

Replace the current node with the code.

```ruby
{% raw %}
replace_with "create({{arguments}})"
{% endraw %}
```

### remove

Remove the current node.

```ruby
with_node type: 'send', message: 'rename_index' do
  remove
end
```

### replace\_erb\_stmt\_with\_expr

Replace erb statemet code with expression code.

```ruby
with_node type: 'block', caller: {type: 'send', receiver: nil, message: 'form_for'} do
  replace_erb_stmt_with_expr
end
```

### warn

Don't change any code, but will give a warning message.

```ruby
warn 'Using a return statement in an inline callback block causes a LocalJumpError to be raised when the callback is executed.'
```

### add\_snippet

Add other snippet, it's easy to reuse other snippets.

```ruby
add_snippet 'rails', 'convert_dynamic_finders'
```

### helper\_method

Add a method which is available in the current snippet.

```ruby
helper_method :method1 do |arg1, arg2|
  # do anything you want
end

method1(arg1, arg2)
```

### todo

List somethings the snippet should do, but not do yet.

```ruby
todo <<-EOF
Rails 4.0 no longer supports loading plugins from vendor/plugins. You
must replace any plugins by extracting them to gems and adding them to
your Gemfile. If you choose not to make them gems, you can move them
into, say, lib/my_plugin/* and add an appropriate initializer in
config/initializers/my_plugin.rb.
EOF
```

[1]: /rules/
