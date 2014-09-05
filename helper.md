---
layout: page
title: Helper
---

Synvert provides some global helper methods that you can use in any snippet.

### add\_receiver\_if\_necessary

It adds the receiver if original node contains receiver.

It's useful when you want to replace code but original code receiver can
be present or nil.

```ruby
with_node type: 'send', message: 'find', arguments: {size: 1, first: :all} do
  replace_with add_receiver_if_necessary("all")
end

# Post.find(:all) => Post.all
# find(:all) => all
```

### strip\_brackets

It strips leading `{[(` and trailing `}])`

```ruby
strip_brackets "{foo: 'bar'}"
# => "foo: 'bar'

strip_brackets "['foo', 'bar']"
# => "'foo', 'bar'"

strip_brackets "(foo, bar)"
# => "foo, bar"
```

Synvert also requires `active_support/core_ext/object`, so you can use
lots of helper methods introduced in `active_support/core_ext/object`.

Check out helper source code [here][1]

[1]: https://github.com/xinminlabs/synvert-core/blob/master/lib/synvert/core/rewriter/helper.rb
