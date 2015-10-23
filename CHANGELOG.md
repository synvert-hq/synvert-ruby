# CHANGELOG

Try to keep same version to gem `synvert-core`.

## 0.9.0

* Add `-o` or `--open` option` to open a snippet

## 0.5.3

* Show warning message if rewriter not found

## 0.5.0

* Rewrite cli for rewriter group

## 0.4.2

* Tell user to update synvert-core if necessary after syncing snippets.

## 0.4.0

* Use synvert-core 0.4.0

## 0.2.0

* Output rewriter warnings
* Ask to run `synvert --sync` if no snippet available

## 0.1.0

* Abstract synvert-core and synvert-snippets

## 0.0.17

* Polish convert_rails_dynamic_finders snippet.
* Add --skip option to cli to skip files and directories.

## 0.0.16

* Add -v, --version cli option.
* Ouput file and line number if there's syntax error.
* Add check_syntax snippet.

## 0.0.15

* Support attr_protected for strong_parameters snippet.

## 0.0.14

* Complement code comments.
* Add MethodNotSupported and RewriterNotFound exceptions.
* Add description dsl to define multi lines description.
* Improve cli, query snippets and show snippet.
* Process rewriter in sandbox mode.

## 0.0.13

* Add keys and values rules for hash node
* Add key and value rules for pair node
* Add ruby new hash syntax snippet
* Add ruby new lambda syntax snippet

## 0.0.12

* Allow define multiple scopes and conditions in one instance
* Polish snippets

## 0.0.11

* Rename gem_spec to if_gem dsl

## 0.0.10

* Add not ast node operator
* Replace with multipe line code
* Add RSpec new syntax snippet

## 0.0.9

* Add add_file dsl
* Upgrade rails 3.0 to 3.1 snippet

## 0.0.8

* Supports travis-ci and coveralls
* Upgrade rails 3.1 to 3.2 snippet

## 0.0.7

* Able to run run specified snippets
* Able to load additional snippets
* Able to list available snippets
* Add helper_method dsl
* Add todo dsl
* Improve rails 3.2 upgrade to 4.0 snippet

## 0.0.6

* Add -> {} only when not exist in rails upgrade snippet
* Add travis support

## 0.0.5

* Add add_snippet dsl for reuse
* Abstract strong_parameters and convert_dynamic_finders snippet

## 0.0.4

* Test snippets
* Lazily execute blocks that allows executing any ruby code
* Be able to save parsed data and use them later

## 0.0.3

* Add snippet to upgrade rails 3.2 to rails 4.0

## 0.0.2

* Rewrite all stuff, dsl style rather than inherit Parser::Rewriter

## 0.0.1

* First version
