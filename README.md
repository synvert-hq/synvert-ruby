# Synvert

[![Build Status](https://secure.travis-ci.org/xinminlabs/synvert.png)](http://travis-ci.org/xinminlabs/synvert)
[![Coverage Status](https://coveralls.io/repos/xinminlabs/synvert/badge.png?branch=master)](https://coveralls.io/r/xinminlabs/synvert)

synvert = syntax + convert, makes it easy to rewrite ruby code
automatically.

**synvert is still in alpha stage**

## Installation

Install it using rubygems

```
$ gem install synvert
```

## Usage

```
$ synvert -h
Usage: synvert [options] [project_path]
        --load-snippets SNIPPET_PATHS
                                     load additional snippets, snippet paths can be local file path or remote http url
        --list-snippets              list all available snippets
        --run-snippets SNIPPET_NAMES run specified snippets
```

e.g.

```
$ synvert --list-snippets
```

```
$ synvert --run-snippets factory_girl_short_syntax,upgrade_rails_3_2_to_4_0 ~/Sites/railsbp/rails-bestpractices.com
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
