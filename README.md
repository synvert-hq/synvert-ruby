# synvert-ruby

<img src="https://synvert.net/img/logo_96.png" alt="logo" width="32" height="32" />

[![AwesomeCode Status for xinminlabs/synvert-ruby](https://awesomecode.io/projects/47cd9805-171c-4c61-b927-baa46cd4020a/status)](https://awesomecode.io/repos/xinminlabs/synvert-ruby)
![Main workflow](https://github.com/xinminlabs/synvert-ruby/actions/workflows/main.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/synvert.svg)](http://badge.fury.io/rb/synvert)

`synvert-ruby` is a command tool to rewrite ruby code automatically, it depends on `synvert-core-ruby` and `synvert-snippets-ruby`.

[synvert-core-ruby](https://github.com/xinminlabs/synvert-core-ruby) provides a set of DSLs to rewrite ruby code.

[synvert-snippets-ruby](https://github.com/xinminlabs/synvert-snippets-ruby) provides official snippets to rewrite ruby code.

## Installation

To install the latest version, run


```
$ gem install synvert
```

This will also install `synvert-core-ruby`.

Synvert is completely working with remote snippets on github,
but you can sync all official snippets locally to make it run faster.

```
$ synvert-ruby --sync
```

Then you can use synvert to rewrite your ruby code, e.g.

```
$ synvert-ruby -r factory_bot/use_short_syntax
```

## Usage

```
$ synvert-ruby -h
Usage: synvert-ruby [project_path]
    -l, --list                       list all available snippets
    -q, --query QUERY                query specified snippets
    -s, --show SNIPPET_NAME          show specified snippet description, SNIPPET_NAME is combined by group and name, e.g. ruby/new_hash_syntax
    -o, --open SNIPPET_NAME          Open a snippet
    -g, --generate NEW_SNIPPET_NAME  generate a new snippet
        --sync                       sync snippets
        --execute EXECUTE_COMMAND    execute snippet
    -r, --run SNIPPET_NAME           run a snippet with snippet name, e.g. ruby/new_hash_syntax, or remote url, or local file path
    -t, --test SNIPPET_NAME          test a snippet with snippet name, e.g. ruby/new_hash_syntax, or remote url, or local file path
        --show-run-process           show processing files when running a snippet
        --only-paths DIRECTORIES     only specified files or directories, separated by comma, e.g. app/models,app/controllers
        --skip-paths FILE_PATTERNS   skip specified files or directories, separated by comma, e.g. vendor/,lib/**/*.rb
    -f, --format FORMAT              output format
        --number-of-workers NUMBER_OF_WORKERS
                                     set the number of workers, if it is greater than 1, it tests snippet in parallel
        --double-quote               prefer double quote, it uses single quote by default
    -v, --version                    show this version
```

### Sync snippets

[Official Snippets](https://github.com/xinminlabs/synvert-snippets-ruby) are available on github,
you can sync them any time you want.

```
$ synvert-ruby --sync
```

### List snippets

List all available snippets

```
$ synvert-ruby -l

$ synvert-ruby --list --format json
```

### Show a snippet

Describe what a snippet does.

```
$ synvert-ruby -s factory_bot/use_short_syntax
```

### Open a snippet

Open a snippet in your editor, editor is defined in
`ENV['SNIPPET_EDITOR']` or `ENV['EDITOR']`

```
$ synvert-ruby -o factory_bot/use_short_syntax
```

### Run a snippet

Run a snippet, analyze and then rewrite code.

```
$ synvert-ruby -r factory_bot/use_short_syntax ~/Sites/xinminlabs/synvert-core-ruby
```

Run a snippet from remote url

```
$ synvert-ruby -r https://raw.githubusercontent.com/xinminlabs/synvert-snippets-ruby/master/lib/factory_bot/use_short_syntax.rb ~/sites/xinminlabs/synvert-core-ruby
```

Run a snippet from local path

```
$ synvert-ruby -r ~/.synvert-ruby/lib/factory_bot/use_short_syntax.rb ~/sites/xinminlabs/synvert-core-ruby
```

Skip paths

```
$ synvert-ruby -r factory_bot/use_short_syntax --skip-paths vendor/ ~/sites/xinminlabs/synvert-core-ruby
```

Only paths

```
$ synvert-ruby -r factory_bot/use_short_syntax --only-paths app/models/ ~/sites/xinminlabs/synvert-core-ruby
```

Show processing files when running a snippet.

```
$ synvert-ruby -r factory_bot/use_short_syntax --show-run-process ~/Sites/xinminlabs/synvert-core-ruby
```

### Generate a snippet

Generate a new snippet

```
$ synvert-ruby -g ruby/convert_foo_to_bar
```
