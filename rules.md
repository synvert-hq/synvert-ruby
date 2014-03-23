---
layout: page
title: Rules
---

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
(begin
  (send nil :include
    (const
      (const nil :EmailSpec) :Helpers))
  (send nil :include
    (const
      (const nil :EmailSpec) :Matchers))))
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
