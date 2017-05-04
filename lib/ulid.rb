# based on https://github.com/rafaelsales/ulid | https://github.com/alizain/ulid
# with assistance from https://github.com/oklog/ulid/
#
# An ULID is a 16 byte Universally Unique Lexicographically Sortable Identifier
#
# In its string representation, it's a compact, URL-friendly, Base32, unique ID
# string that encodes its time of creation and sorts according the time value it
# encodes.
#
# A ULID string looks like this:
#
#     > require 'ulid'
#     > ULID.generate
#     => "0DHWZV7PGEAFYDYH04X7Y468GQ"
#
# The two parts of a ULID are Timestamp and Entropy.
#
#  0DHWZV7PGE      AFYDYH04X7Y468GQ
# |----------|    |----------------|
#  Timestamp            Entropy
#    48bits             80bits
#
# Timestamp
#
# - 48 bit integer
# - UNIX-time in milliseconds
# - Won't run out of space till the year 10895 AD.
#
#
# Entropy
#
# - 80 bits
# - Cryptographically secure source of randomness
# - Unlikely to duplicate even with millions of IDs at the same millisecond
#
#
# Sorting
#
# The left-most character must be sorted first, and the right-most character
# sorted last (lexical order). The default ASCII character set must be used.
# Within the same millisecond, sort order is not guaranteed.
#
#
# Usage
#
# Getting a new ULID string quickly:
#
#   ULID.generate # => 0DHWZV7PGEAFYDYH04X7Y468GQ
#
# Getting a ULID at a particular time:
#
#   ULID.at Time.now # => 0DHWZV7PGEAFYDYH04X7Y468GQ
#   ULID.at Time.at(1_000_000) # => 0009A0QS00SGEFTGMFFEAS6B9A
#
# Min and Max ULIDs for help with queries:
#
#   ULID.max_ulid_at Time.at(1_000_000) # => 0009A0QS000000000000000000
#   ULID.min_ulid_at Time.at(1_000_000) # => 0009A0QS00ZZZZZZZZZZZZZZZZ
#
# Parsing:
#
#   ulid = ULID.new "0009A0QS00SGEFTGMFFEAS6B9A"
#   => #<ULID:0x007fc9348a4c10 ...>
#
#   ulid.time.utc
#   => "1970-01-12T13:46:40.000Z"
#
#   ulid.seed
#   => "\xCC\x1C\xFDB\x8F{\x95\x93-*"
#
#   ulid.ulid
#   => "0009A0QS00SGEFTGMFFEAS6B9A"
#
#   ULID.time('0009A0QS00SGEFTGMFFEAS6B9A')
#   => "1970-01-12T08:46:40.000-05:00"
#

require 'time'
require 'securerandom'

require 'ulid/version'
require 'ulid/constants'
require 'ulid/identifier'
require 'ulid/generate'
require 'ulid/parse'
require 'ulid/compare'

module ULID
  include Constants


  # Get a new, randomized ULID string at the current time.
  def self.generate
    Identifier.new.ulid
  end

  def self.at(at_time)
    Identifier.new(at_time).ulid
  end

  # Get the Time value encoded by the given ULID string.
  #
  # @param ulid [String or ULID::Identifier]
  def self.time(ulid)
    Identifier.new(ulid).time.utc
  end

  # Get the first possible ULID string for the given time in sort order ascending.
  def self.min_ulid_at(at_time)
    Identifier.new(at_time, MIN_ENTROPY).ulid
  end

  # Get the first possible ULID string for the given time in sort order descending.
  def self.max_ulid_at(at_time)
    Identifier.new(at_time, MAX_ENTROPY).ulid
  end

end

