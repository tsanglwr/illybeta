# TypeScript for Rails [![Build Status](https://travis-ci.org/typescript-ruby/typescript-rails.svg?branch=master)](https://travis-ci.org/typescript-ruby/typescript-rails) [![Coverage Status](https://coveralls.io/repos/typescript-ruby/typescript-rails/badge.png)](https://coveralls.io/r/typescript-ruby/typescript-rails)

This is a wrapper for the [TypeScript](http://www.typescriptlang.org/), JavaScript superset language by Microsoft.

It enables you to use the `.ts` extension in the Asset Pipeline and also in ActionView Templates.

This gem uses the
[typescript-node-ruby](https://github.com/typescript-ruby/typescript-node-ruby)
library by KAWACHI Takashi for the typescript parsing with node js.

The credit for the overall structure and the tests goes to the people that wrote the [coffee-rails](https://github.com/rails/coffee-rails) Gem, since I shamelessly copy&pasted some of their code.

## Requirements

The current version requires that [node.js](http://nodejs.org/) is
installed on the system.

The requirement for node is tested upon starting the application. If
the node command is not available you get the following error message:

```
typescript-node requires node command, but it's not found. Please install it. Set TS_NODE environmental variable If you want to use node command in non-standard path.
```

## Installation

Add this line to your application's Gemfile:

    gem 'typescript-rails'

And then execute:

    $ bundle

## Usage

Just add a `.js.ts` file in your `app/assets/javascripts` directory and include it just like you are used to do.

Configurations:

```
# Its defaults are `--target ES5 --noImplicitAny`.
Typescript::Rails::Compiler.default_options = [ ... ]
```

## Referenced TypeScript dependencies

`typescript-rails` recurses through all [TypeScript-style](https://github.com/teppeis/typescript-spec-md/blob/master/en/ch11.md#1111-source-files-dependencies) referenced files and tells its [`Sprockets::Context`](https://github.com/sstephenson/sprockets/blob/master/lib/sprockets/context.rb) that the TS file being processed [`depend`s`_on`](https://github.com/sstephenson/sprockets#the-depend_on-directive) each file listed as a reference. This activates Sprocket’s cache-invalidation behavior when any of the descendant references of the root TS file is changed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Maintainers

FUJI Goro <gfuji@cpan.org>

## Authors

Klaus Zanders <klaus.zanders@gmail.com>

