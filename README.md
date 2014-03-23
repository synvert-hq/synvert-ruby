# Synvert

[![Build Status](https://secure.travis-ci.org/xinminlabs/synvert.png)](http://travis-ci.org/xinminlabs/synvert)

synvert = syntax + convert, makes it easy to rewrite ruby code
automatically.

**synvert is still in alpha stage**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'synvert'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install synvert
```

## Usage

```
$ synvert -h
Usage: synvert [project_path]
        --list-snippets
        --snippets SNIPPETS          run specified snippets
```

## Snippets

name | description
--- | ---
factory_girl_short_syntax | FactoryGirl uses short syntax
convert_dynamic_finders | Convert dynamic finders
strong_parameters | Use strong_parameters syntax
upgrade_rails_3_2_to_4_0 | Upgrade rails from 3.2 to 4.0, it contains convert_dynamic_finder and strong_parameters snippets

## Documentation

[http://xinminlabs.github.io/synvert/][1]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://xinminlabs.github.io/synvert/
