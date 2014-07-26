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

### describe what snippet does

```ruby
description 'descriptin of rewriter'
```

`description` describes what the rewriter does.

### check gem version

```ruby
if_gem 'factory_girl', {eq: '2.0.0'}
if_gem 'factory_girl', {ne: '2.0.0'}
if_gem 'factory_girl', {gt: '2.0.0'}
if_gem 'factory_girl', {lt: '2.0.0'}
if_gem 'factory_girl', {gte: '2.0.0'}
if_gem 'factory_girl', {lte: '2.0.0'}
```

`if_gem` checks the gem in `Gemfile.lock`, if gem version in
`Gemfile.lock` is less than, greater than or equal to the version in
`if_gem`, the rewriter will be executed, otherwise, the rewriter
will be ignored.

### add file

```ruby
add_file 'config/initializers/wrap_parameters.rb', """
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
""".strip
```

`add_file` adds a new file and writes the content.

### remove file

```ruby
remove_file 'config/initiliazers/secret_token.rb'
```

`remove_file` removes a file.

### match file / files

```ruby
within_file 'spec/spec_helper.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

`within_file` finds matching file according to file\_pattern, the block
will be executed only for matching file.

```ruby
within_files 'spec/**/*_spec.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

`within_files` is an alias to within\_file, but used to find multiple
files.

### find nodes

```ruby
within_node type: 'class', name: 'Test::Unit::TestCase' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

`within_node` finds ast nodes according to the [rules][1], the block
will be executed for the matching nodes.

```ruby
with_node type: 'send', 'receiver: 'FactoryGirl', message: 'create' do
  # check nodes
  # add / replace / remove code
end
```

`with_node` is an alias to `within_node`, it indicates this is the node
we are looking for and we would do some action on that node.

### check conditions

```ruby
if_exist_node type: 'send', receiver: 'params', message: '[]' do
  # add / replace / remove code
end
```

`if_exist_node` checks if the node matches [rules][1] exists, if
matches, then executes the block to add / replace / remove code.

```ruby
unless_exist_node type: 'send', message: 'include', arguments: ['FactoryGirl::Syntax::Methods'] do
  # add / replace / remove code
end
```

`unless_exist_node` checks if the node matches [rules][1] does not
exist, if does not match, then executes the block.

```ruby
if_only_exist_node type: 'send', receiver: 'self', message: 'include_root_in_json=', arguments: [false] do
  # add / replace / remove code
end
```

`if_only_exist_node` checks if the body of current node contains only
one node and the node matches [rules][1], if matches, then executes the
node.

### add / replace / remove code

```ruby
append 'config.eager_load = false'
```

`append` adds the code at the bottom of the current node.

```ruby
insert "include FactoryGirl::Syntax::Methods"
```

`insert` adds the code at the top of the current node.

```ruby
{% raw %}
secret = SecureRandom.hex(64)
insert_after "{{receiver}}.secret_key_base = '#{secret}'"
{% endraw %}
```

`insert_after` adds the code next to the current node.

```ruby
{% raw %}
replace_with "create({{arguments}})"
{% endraw %}
```

`replace_with` replaces the current node with the code.

```ruby
remove
```

`remove` removes the current node.

### replace erb statement with expression code

```ruby
replace_erb_stmt_with_expr
```

`replace_erb_stmt_with_expr` will replace erb statemet code with expression code, e.g.

```
<% form_for :post do |f| %>
<% end %>

=>

<%= form_for :post do |f| %>
<% end %>
```

### warn code

```ruby
warn 'Using a return statement in an inline callback block causes a LocalJumpError to be raised when the callback is executed.'
```

`warn` doesn't change any code, but will give a warning message.

### add other snippet

```ruby
add_snippet 'convert_dynamic_finders'
```

`add_snippet` adds other snippet, it's easy to reuse snippets.


### add helper methods

```ruby
helper_method 'dynamic_finder_to_hash' do |prefix|
  fields = node.message.to_s[prefix.length..-1].split("_and_")
  fields.length.times.map { |i|
    fields[i] + ": " + node.arguments[i].to_source
  }.join(", ")
end
```

`helper_method` dynamically adds methods to all instances in the current
rewriter.

#### add todo list

```ruby
todo <<-EOF
Rails 4.0 no longer supports loading plugins from vendor/plugins. You
must replace any plugins by extracting them to gems and adding them to
your Gemfile. If you choose not to make them gems, you can move them
into, say, lib/my_plugin/* and add an appropriate initializer in
config/initializers/my_plugin.rb.
EOF

`todo` is a list that developers have to do by themselves or anything
you want to warn developers.

[1]: /rules/
