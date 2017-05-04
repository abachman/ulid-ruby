<h1 align="center">
    <br>
    <br>
    <img width="360" src="logo.png" alt="ulid">
    <br>
    <br>
    <br>
</h1>

## -- unofficial --

# ULID

A ULID is a "Universally Unique Lexicographically-sortable Identifier." This is a thin Ruby library for generating and parsing ULID values. This code is based on the original concept presented at https://github.com/alizain/ulid and in part based on code from the C# and Go projects at https://github.com/RobThree/NUlid and https://github.com/oklog/ulid  respectively.

**NOTE:** while the ULID values generated are compatible with the existing Ruby ULID library located at https://github.com/rafaelsales/ulid, this library is not code-compatible. I needed some additional features for a project and it was easier to just rebuild the functionality. May not be useful for anyone else but it's working for us in production at https://io.adafruit.com.

In its string representation, it's a compact, URL-friendly, Base32, unique ID string that encodes its time of creation and sorts according the time value it encodes.

A ULID string looks like this:

```ruby
require 'ulid'
ULID.generate #=> "0DHWZV7PGEAFYDYH04X7Y468GQ"
```

## Short Explanation

The two parts of a ULID are **Timestamp** and **Entropy**.

     0DHWZV7PGE      AFYDYH04X7Y468GQ
    |----------|    |----------------|
     Timestamp            Entropy
       48bits             80bits

### Timestamp

- Encoded in first 48 bits of ULID. In Base32 it's the first 10 ASCII characters.
- UNIX-time with a precision of milliseconds.
- Won't run out of space till the year 10895 AD.

### Entropy

- Encoded in last 80 bits of ULID. In Base32 it's the last 16 ASCII characters.
- Should use cryptographically secure source of randomness (this library uses the Ruby Standard Library's `SecureRandom` class)
- Unlikely to duplicate even with millions of IDs at the same millisecond

### Sorting

The left-most character must be sorted first, and the right-most character sorted last (lexical order). The default ASCII character set must be used. Within the same millisecond, sort order is not guaranteed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ulid-ruby', require: 'ulid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ulid-ruby

And require from your project with:

```ruby
require 'rubygems'
require 'ulid'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abachman/ulid-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

