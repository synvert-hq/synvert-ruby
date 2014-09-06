---
layout: page
title: Rules
---

synvert compares ast nodes with key / value pairs, each ast node has
multiple attributes, e.g. `receiver`, `message` and `arguments`, it
matches only when all of key / value pairs match.

```ruby
type: 'send', message: :include, arguments: ['FactoryGirl::Syntax::Methods']
```

synvert does comparison based on the value type

1. if value is a symbol, then compares ast node value as symbol, e.g.
   `message: :include`
2. if value is a string, then compares ast node original source code,
   e.g. `name: 'Synvert::Application'`
3. if value is a regexp, then compares ast node original source code,
   e.g. `message: /find_all_by_/`
4. if value is an array, then compares each ast node, e.g. `arguments:
   ['FactoryGirl::Syntax::Methods']`
5. if value is nil, then check if ast node is nil, e.g. `arguments:
   [nil]`
6. if value is true or false, then check if ast node is :true or :false,
   e.g. `arguments: [false]`
7. if value is ast, then compare ast node directly, e.g. `to_ast:
   Parser::CurrentRuby.parse("self.class.serialized_attributes")`

it can compare nested key / value pairs, like

```ruby
# matches config.activerecord.identity_map = ...
type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'identity_map='
```

## Source code to ast node

### command line

```
$ ruby-parse -e 'RSpec.configure do |config|; include EmailSpec::Helpers; include EmailSpec::Matchers; end'

(block
  (send
    (const nil :RSpec) :configure)
  (args
    (arg :config))
  (begin
    (send nil :include
      (const
        (const nil :EmailSpec) :Helpers))
    (send nil :include
      (const
        (const nil :EmailSpec) :Matchers))))
```

### ruby code

```ruby
require 'parser/current'

code =<<-EOF
RSepc.configure do |config|
  include EmailSpec::Helpers
  include EmailSpec::Matchers
end
EOF

Parser::CurrentRuby.parse code

# (block
#   (send
#     (const nil :RSpec) :configure)
#   (args
#     (arg :config))
#   (begin
#     (send nil :include
#       (const
#         (const nil :EmailSpec) :Helpers))
#     (send nil :include
#       (const
#         (const nil :EmailSpec) :Matchers))))
```

## AST node attributes

AST node is just an array, by default, it has only 2 attributes,
the first element is `type`, the others are `children`.

```ruby
node = Parser::CurrentRuby.parse "user = User.new"
# (lvasgn :user
#   (send
#     (const nil :User) :new))

node.type
# => :lvasgn

node.children
# [:user, (send (const nil :User) :new))
```

synvert adds many additional attributes.

### :send node

`receiver`, `message` and `arguments` attributes for :send node.

```ruby
node = Parser::CurrentRuby.parse "User.find 1"
# (send
#   (const nil :User) :find
#     (int 1))

node.receiver
# => (const nil :user)

node.message
# => :find

node.arguments
# [(int 1)]
```

### :class node

`name`, `parent_class` for :class node.

```ruby
node = Parser::CurrentRuby.parse "class Admin < User; end"
# (class
#   (const nil :Admin)
#     (const nil :User) nil)

node.name
# => (const nil :Admin)

node.parent_class
# => (const nil :User)
```

### :module node

`name` for :module node.

```ruby
node = Parser::CurrentRuby.parse "module Helper; end"
# (module
#   (const nil :Helper) nil)

node.name
# (const nil Helper)
```

### :def node

`name`, `arguments` and `body` for :def node.

```ruby
code =<<-EOC
def full_name(first_name, last_name)
  first_name + " " + last_name
end
EOC
node = Parser::CurrentRuby.parse code
# (def :full_name
#   (args
#     (arg :first_name)
#     (arg :last_name))
#   (send
#     (send
#       (lvar :first_name) :+
#       (str " ")) :+
#     (lvar :last_name)))

node.name
# :full_name

node.arguments
# (args (arg :first_name) (arg :last_name))

node.body
# (send (send (lvar :first_name) :+ (str " ")) :+ (lvar :last_name))
```

### :defs node

`name` and `body` for :defs node.

```ruby
code =<<EOC
def self.active
  where(active: true)
end
EOC
node = Parser::CurrentRuby.parse code
# (defs
#   (self) :active
#   (args)
#   (send nil :where
#     (hash
#       (pair
#         (sym :active)
#         (true)))))

node.name
# :active

node.arguments
# (send nil :where (hash (pair (sym :active) (true))))
```

### :block node

`caller`, `arguments` and `body` for :block node.

```ruby
code =<<-EOC
RSpec.configure do |config|
  config.order = 'random'
end
EOC
node = Parser::CurrentRuby.parse code
# (block
#   (send
#     (const nil :RSpec) :configure)
#   (args
#     (arg :config))
#   (send
#     (lvar :config) :order=
#     (str "random")))

node.caller
# (send (const nil :RSpec) :configure)

node.arguments
# (args (arg :config))

node.body
# (send (lvar :config) :order= (str "random"))
```

### :defined? node

`arguments` for :defined? node.

```ruby
node = Parser::CurrentRuby.parse "defined?(User)"
# (defined?
#   (const nil :User))

node.arguments
# [(const nil :User)]
```

### hash node

`keys`, `values` for :hash node.

```ruby
node = Parser::CurrentRuby.parse "{first_name: 'richard', last_name: 'huang'}"
# (hash
#   (pair
#     (sym :first_name)
#     (str "richard"))
#   (pair
#     (sym :last_name)
#     (str "huang")))

node.keys
# [(sym :first_name), (sym :last_name)]

node.values
# [(str "richard"), (str "huang")]
```

### pair node

`key` and `value` for :pair node.

```ruby
node = Parser::CurrentRuby.parse("{first_name: 'richard', last_name: 'huang'}").children.first
# (pair
#   (sym :first_name)
#   (str "richard"))

node.key
# (sym :first_name)

node.value
# (str "richard")
```

## AST node method

### has_key?(key)

check if :hash node contains key.

```ruby
node = Parser::CurrentRuby.parse "{first_name: 'richard', last_name: 'huang'}"
# (hash
#   (pair
#     (sym :first_name)
#     (str "richard"))
#   (pair
#     (sym :last_name)
#     (str "huang")))

node.has_key? :first_name
# true

node.has_key? :full_name
# false
```

### hash_value(key)

fetch value for specified hash key.

```ruby
node = Parser::CurrentRuby.parse "{first_name: 'richard', last_name: 'huang'}"
# (hash
#   (pair
#     (sym :first_name)
#     (str "richard"))
#   (pair
#     (sym :last_name)
#     (str "huang")))

node.hash_value :first_name
# (str "richard")
```

### to_source

return exactly source code for an ast node.

```ruby
node = Parser::CurrentRuby.parse "{first_name: 'richard', last_name: 'huang'}"
node.to_source
# {first_name: 'richard', last_name: 'huang'}
```

### to_value

returns exactly value for an ast node.

```ruby
node = Parser::CurrentRuby.parse "{first_name: 'richard', last_name: 'huang'}"
node.hash_value(:first_name).to_value
# "richard"
```

## AST node operator

### any

Any child node matches.

```ruby
node = Parser::CurrentRuby.parse "config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions"
# (send
#   (send
#     (send nil :config) :middleware) :swap
#   (const
#     (const nil :ActionDispatch) :ShowExceptions)
#   (const
#     (const nil :Lifo) :ShowExceptions))
```

matches

```ruby
type: 'send', arguments: {any: 'Lifo::ShowExceptions'}
```

### not

Not matches.

```ruby
node = Parser::CurrentRuby.parse "obj.should matcher"
# (send
#   (send nil :obj) :should
#   (send nil :matcher))
```

matches

```ruby
type: 'send', receiver: {not: nil}, message: 'should'
```

If you want to get more, please read [here][1].

[1]: https://github.com/xinminlabs/synvert-core/blob/master/lib/synvert/core/node_ext.rb
