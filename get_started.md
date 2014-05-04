---
layout: page
title: Get Started
---

### Installation

Synvert is distributed using [RubyGems][1].

To install the latest version, run

```
$ gem install synvert
```

This will install Synvert, along with all of it's require dependencies.

### Usage

Now you can use synvert to convert your ruby code.

```
$ synvert -h
Usage: synvert [project_path]
    -d, --load SNIPPET_PATHS         load custom snippets, snippet paths can be local file path or remote http url
    -l, --list                       list all available snippets
    -q, --query QUERY                query specified snippets
        --skip FILE_PATTERNS         skip specified files or directories, separated by comma, e.g.  app/models/post.rb,vendor/plugins/**/*.rb
    -s, --show SNIPPET_NAME          show specified snippet description
        --sync                       sync snippets
    -r, --run SNIPPET_NAMES          run specified snippets
    -v, --version                    show this version
```
First you should sync [snippets][2] from github

```
$ synvert --sync
```

list all available snippets

```
$ synvert -l
```

run snippets `factory_girl_short_syntax`, `rspec_new_syntax` and
`upgrade_rails_3_2_to_4_0` in rails-bestpractices.com repo.

```
$ synvert -r factory_girl_short_syntax,rspec_new_syntax,upgrade_rails_3_2_to_4_0 ~/Sites/railsbp/rails-bestpractices.com
```

It's recommended that you use version control software like [git][3],
after using synvert, you can use check what changes synvert does to
your ruby code.

You can write your own snippets then load them by `--load`.

### Dependencies

Synvert uses [parser][4] and [ast][5], parser helps to parse ruby source
code and rewrite ast nodes, ast is a small library for working with
immutable abstract syntax trees. It's highly recommended to look through
these 2 libraries.

[1]: https://rubygems.org
[2]: https://github.com/xinminlabs/synvert-snippets
[3]: http://git-scm.com/
[4]: https://github.com/whitequark/parser
[5]: https://github.com/whitequark/ast
