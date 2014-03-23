---
layout: page
title: DSL
---

Synvert provides a simple dsl to define a snippet.

```ruby
Synvert::Rewriter.new "name", "description" do
  gem_spec gem_name, gem_version

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

### check gem version

```ruby
gem_spec 'factory_girl', '2.0.0'
```

`gem_spec` checks the gem in `Gemfile.lock`, if gem version in
`Gemfile.lock` is greater than or equal to the version in `gem_spec`,
the rewriter will be executed, otherwise, the rewriter will be ignored.

### match file / files

```ruby
within_file 'spec/spec_helper.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

`within_file` finds matching file according to file_pattern, the block
will be executed only for matching file.

```ruby
within_files 'spec/**/*_spec.rb' do
  # find nodes
  # check nodes
  # add / replace / remove code
end
```

`within_files` is an alias to within_file, but used to find multiple
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

[1]: /rules/
