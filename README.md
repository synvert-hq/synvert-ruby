# Synvert

synvert = syntax + convert, makes it easy to rewrite ruby code
automatically.

**synvert is still in alpha stage**

## Installation

Add this line to your application's Gemfile:

    gem 'synvert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synvert

## Usage

    synvert PROJECT_PATH

Currently it supports

* convert to FactoryGirl short syntax
* upgrade rails from 3.2.x to 4.0.0

## Example

```ruby
Synvert::Rewriter.new "factory_girl_short_syntax", "FactoryGirl uses short syntax" do
  within_file 'sepc/**/*.rb' do
    with_node type: 'send', receiver: 'FactoryGirl', message: 'create' do
      replace_with "create({{arguments}})"
    end
  end
end
```

This snippet will convert `post = FactoryGirl.create(:post)` to `post =
create(:post)`.

There are more examples [here][1], I will write down the Documents
later.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[1]: https://github.com/xinminlabs/synvert/tree/master/lib/synvert/snippets
