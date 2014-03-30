# Synvert

[![Build Status](https://secure.travis-ci.org/xinminlabs/synvert.png)](http://travis-ci.org/xinminlabs/synvert)
[![Coverage Status](https://coveralls.io/repos/xinminlabs/synvert/badge.png?branch=master)](https://coveralls.io/r/xinminlabs/synvert)
[![Gem Version](https://badge.fury.io/rb/synvert.png)](http://badge.fury.io/rb/synvert)

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
factory_girl_short_syntax                | FactoryGirl uses short syntax
convert_dynamic_finders                  | Convert dynamic finders
strong_parameters                        | Use strong_parameters syntax
upgrade_rails_3_0_to_3_1                 | Upgrade rails from 3.0 to 3.1
upgrade_rails_3_1_to_3_2                 | Upgrade rails from 3.1 to 3.2
upgrade_rails_3_2_to_4_0                 | Upgrade rails from 3.2 to 4.0, it contains convert_dynamic_finder and strong_parameters snippets
convert_rspec_be_close_to_be_within      | RSpec converts be_close to be_within
convert_rspec_block_to_expect            | RSpec converts block to expect
convert_rspec_boolean_matcher            | RSpec converts boolean matcher
convert_rspec_collection_matcher         | RSpec converts collection matcher
convert_rspec_its_to_it                  | RSpec converts its to it
convert_rspec_message_expectation        | RSpec converts message expectation
convert_rspec_method_stub                | RSpec converts method stub
convert_rspec_negative_error_expectation | RSpec converts negative error expectation
rspec_new_syntax                         | Use RSpec new syntax, it contains all convert_rspec_* snippets
convert_rspec_one_liner_expectation      | RSpec converts one liner expectation
convert_rspec_should_to_expect           | RSpec converts should to expect
convert_rspec_stub_and_mock_to_double    | RSpec converts stub and mock to double

## Documentation

[http://xinminlabs.github.io/synvert/][1]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://xinminlabs.github.io/synvert/
