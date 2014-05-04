# Synvert

[![Build Status](https://secure.travis-ci.org/xinminlabs/synvert.png)](http://travis-ci.org/xinminlabs/synvert)
[![Coverage Status](https://coveralls.io/repos/xinminlabs/synvert/badge.png?branch=master)](https://coveralls.io/r/xinminlabs/synvert)
[![Gem Version](https://badge.fury.io/rb/synvert.png)](http://badge.fury.io/rb/synvert)

synvert = syntax + convert, makes it easy to rewrite ruby code
automatically.

**synvert is still in alpha stage**

synvert supports ruby >= 1.9.3

## Installation

Install it using rubygems

```
$ gem install synvert
```

## Usage

```
$ synvert -h
Usage: synvert [project_path]
    -d, --load SNIPPET_PATHS         load custom snippets, snippet paths can be local file path or remote http url
    -l, --list                       list all available snippets
    -q, --query QUERY                query specified snippets
        --skip FILE_PATTERNS         skip specified files or directories, separated by comma, e.g. app/models/post.rb,vendor/plugins/**/*.rb
    -s, --show SNIPPET_NAME          show specified snippet description
        --sync                       sync snippets
    -r, --run SNIPPET_NAMES          run specified snippets
    -v, --version                    show this version
```

e.g.

```
$ synvert --sync
```

```
$ synvert -r factory_girl_short_syntax,upgrade_rails_3_2_to_4_0 ~/Sites/railsbp/rails-bestpractices.com
```

## Snippets

[https://github.com/xinminlabs/synvert-snippets/][1]

## Documentation

[http://xinminlabs.github.io/synvert/][2]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://github.com/xinminlabs/synvert-snippets/
[2]: http://xinminlabs.github.io/synvert/
