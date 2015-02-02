# PrettyBacktrace

Pretty your exception backtrace.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pretty_backtrace'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pretty_backtrace

## Usage

Use like that:

```ruby
require 'pretty_backtrace'
PrettyBacktrace.enable

def recursive n
  str = "Hi #{n}!!" * 128
  if n > 0
    recursive n - 1
  else
    raise "bottom of recursive"
  end
end

recursive 3
```

and you can see prettier backtrace (you can see local variable names and values).

```
test.rb:10:in `recursive' (n = 0, str = "Hi 0!!Hi 0!!Hi 0!!Hi...): bottom of recursive (RuntimeError)
        from test.rb:8:in `recursive' (n = 1, str = "Hi 1!!Hi 1!!Hi 1!!Hi...)
        from test.rb:8:in `recursive' (n = 2, str = "Hi 2!!Hi 2!!Hi 2!!Hi...)
        from test.rb:8:in `recursive' (n = 3, str = "Hi 3!!Hi 3!!Hi 3!!Hi...)
        from test.rb:14:in `<main>'
```

You only need to require "pretty_backtrace/enable" to eliminate "PrettyBacktrace.enable call".

PrettyBacktrace::CONFIG can change behaviour. See source code files for details.

### Multi-line mode

You can use multi-line mode with the following configuration.

```ruby
PrettyBacktrace::CONFIG[:multi_line] = true
```

Multi-line mode enable to show all variables (and pointing values) in each lines like that:

```
test.rb:11:in `recursive'
          n = 0
          str = "Hi 0!!  Hi 0!!  Hi 0!!  Hi 0!!  Hi 0!!  Hi 0!!  Hi 0!!  Hi 0...
: bottom of recursive (RuntimeError)
        from test.rb:9:in `recursive'
          n = 1
          str = "Hi 1!!  Hi 1!!  Hi 1!!  Hi 1!!  Hi 1!!  Hi 1!!  Hi 1!!  Hi 1...

        from test.rb:9:in `recursive'
          n = 2
          str = "Hi 2!!  Hi 2!!  Hi 2!!  Hi 2!!  Hi 2!!  Hi 2!!  Hi 2!!  Hi 2...

        from test.rb:9:in `recursive'
          n = 3
          str = "Hi 3!!  Hi 3!!  Hi 3!!  Hi 3!!  Hi 3!!  Hi 3!!  Hi 3!!  Hi 3...

        from test.rb:15:in `<main>'
```

## Contributing

There are no spec tests. I love to get your contributions!

1. Fork it ( https://github.com/ko1/pretty_backtrace/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
