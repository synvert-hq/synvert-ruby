# Synvert

<img src="https://xinminlabs.github.io/synvert/img/logo_96.png" alt="logo" width="32" height="32" />

![Main workflow](https://github.com/xinminlabs/synvert/actions/workflows/main.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/xinminlabs/synvert/badge.svg?branch=master)](https://coveralls.io/r/xinminlabs/synvert)
[![Gem Version](https://badge.fury.io/rb/synvert.svg)](http://badge.fury.io/rb/synvert)

Synvert = syntax + convert, makes it easy to convert ruby code
automatically.

Synvert is composed by synvert-core and synvert-snippets.

[synvert-core][1] provides a dsl to convert ruby code.

[synvert-snippets][2] lists all snippets to convert ruby code based on
synvert-core.

## Installation

Install it using rubygems

```
$ gem install synvert
```

then run

```
$ synvert --sync
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
$ synvert -r factory_girl/use_short_syntax,rails/upgrade_3_2_to_4_0 ~/Sites/railsbp/rails-bestpractices.com
```

## Docker

We have a docker image to run synvert

```
$ docker pull xinminlabs/awesomecode-synvert

$ docker run xinminlabs/awesomecode-synvert synvert --list

$ docker run -v <your project path>:/app xinminlabs/awesomecode-synvert synvert --run default/check_syntax /app
```

## Documentation

[https://xinminlabs.github.io/synvert/][3]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://github.com/xinminlabs/synvert-core/
[2]: https://github.com/xinminlabs/synvert-snippets/
[3]: https://xinminlabs.github.io/synvert/
