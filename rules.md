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

## Ast node attributes

The followings are all ast node attributes you can use.

### type

type of ast node, e.g. `class`, `def`, `send`.

### name

##### class node

source code

```ruby
class Synvert
end
```

ast node

```
(class
  (const nil :Synvert) nil nil)
```

name

```
(const nil :Synvert)
```

##### module node

source code

```ruby
module Synvert
end
```

ast node

```
(module
  (const nil :Synvert) nil)
```

name

```
(const nil :Synvert)
```

##### def node

source code

```ruby
def synvert
end
```

ast node

```
(def :synvert
  (args) nil)
```

name

```
:synvert
```

##### defs node

source code

```ruby
defs self.current_node
end
```

ast node

```
(defs
  (self) :current_node
  (args) nil)
```

name

```
:current_node
```

### receiver

##### send node

source code

```ruby
FactoryGirl.create :post
```

ast node

```
(send
  (const nil :FactoryGirl) :create
  (sym :post))
```

receiver

```
(const nil :FactoryGirl)
```

### message

##### send node

source code

```ruby
FactoryGirl.create :post
```

ast node

```
(send
  (const nil :FactoryGirl) :create
  (sym :post))
```

message

```
:create
```

### arguments

##### send node

source code

```ruby
FactoryGirl.create :post, title: 'post'
```

ast node

```
(send
  (const nil :FactoryGirl) :create
  (sym :post)
  (hash
    (pair
      (sym :title)
      (send nil :post))))
```

arguments

```
[ (sym :post),
  (hash
    (pair
      (sym :title)
      (send nil :post)))) ]
```

##### block node

source code

```ruby
RSpec.configure do |config|
end
```

ast node

```
(block
  (send
    (const nil :RSpec) :configure)
  (args
    (arg :config)) nil)
```

arguments

```
[ (arg :config) ]
```

##### defined? node

source code

```ruby
defined?(Bundler)
```

ast node

```
(defined?
  (const nil :Bundler))
```

arguments

```
(const nil :Bundler)
```

### caller

##### block node

source code

```ruby
RSpec.configure do |config|
end
```

ast node

```
(block
  (send
    (const nil :RSpec) :configure)
  (args
    (arg :config)) nil)
```

caller

```
(send (const nil :RSpec) :configure)
```

### body

##### begin node

source code

```ruby
foo
bar
```

ast node

```
(begin
  (send nil :foo)
  (send nil :bar))
```

body

```
[ (send nil :foo),
  (send nil :bar)) ]
```

##### block node

source code

```ruby
RSpec.configure do |config|
  include EmailSpec::Helpers
  include EmailSpec::Matchers
end
```

ast node

```
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

body

```
[ (send nil :include
    (const
      (const nil :EmailSpec) :Helpers)),
  (send nil :include
    (const
      (const nil :EmailSpec) :Matchers)))) ]
```

### condition

##### if node

source code

```ruby
if defined?(Bundler)
end
```

ast node

```
(if
  (defined?
    (const nil :Bundler)) nil nil)
```

condition

```
(defined? (const nil :Bundler))
```

## Ast node operator

### any

source code

```ruby
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

ast node

```
(send
  (send
    (send nil :config) :middleware) :swap
  (const
    (const nil :ActionDispatch) :ShowExceptions)
  (const
    (const nil :Lifo) :ShowExceptions))
```

matches

```ruby
type: 'send', arguments: {any: 'Lifo::ShowExceptions'}
```

### not

source code

```ruby
obj.should matcher
```

ast node

```
(send
  (send nil :obj) :should
  (send nil :matcher))
```

matches

```ruby
type: 'send', receiver: {not: nil}, message: 'should'
```
