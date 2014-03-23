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
Usage: synvert [options] [project_path]
        --load-snippets SNIPPET_PATHS
                                     load additional snippets, snippet paths can be local file path or remote http url
        --list-snippets              list all available snippets
        --run-snippets SNIPPET_NAMES run specified snippets
```
list all available snippets

```
$ synvert --list-snippets
```

run snippets `factory_girl_short_syntax` and `upgrade_rails_3_2_to_4_0`
in rails-bestpractices.com repo.

```
$ synvert --run-snippets factory_girl_short_syntax,upgrade_rails_3_2_to_4_0 ~/Sites/railsbp/rails-bestpractices.com
```

It's recommended that you use version control software like [git][2],
after using synvert, you can use check what changes synvert does to
your ruby code.

This has been a very simple walk-through, but you should now have a
general idea of how to install and use synvert.

[1]: https://rubygems.org
[2]: http://git-scm.com/
