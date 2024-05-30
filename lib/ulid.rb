
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

  # Get a new, randomized ULID::Identifier instance at the current time.
  #
  # @return [ULID::Identifier] new ULID::Identifier instance for the current system time
  #
  # @example Generate a ULID
  #   ULID.new #=> #<ULID::Identifier:0x007f83f90aecc0 ....>
  #
  def self.new(*args)
    Identifier.new(*args)
  end

  # Get a new, randomized ULID string at the current time.
  #
  # @return [String] 26 character ULID value for the current system time
  #
  # @example Generate a ULID string
  #   ULID.generate #=> 0DHWZV7PGEAFYDYH04X7Y468GQ
  #
  def self.generate
    Identifier.new.ulid
  end

  # Get a string ULID encoding the given time.
  #
  # @param at_time [Time] the time to encode
  # @return [String] new ULID string encoding the given time
  #
  # @example Generate a ULID string for a given time
  #   ULID.at(Time.at(1_000_000)) #=> 0000XSNJG0H890HQE70THPQ3D3
  #
  def self.at(at_time)
    Identifier.new(at_time).ulid
  end

  # Get the Time value encoded by the given ULID string.
  #
  # @param ulid [String or ULID::Identifier]
  # @return [Time] UTC time value encoded by the ULID
  #
  # @example Parse a ULID string and get a time value
  #   ULID.time '0009A0QS00SGEFTGMFFEAS6B9A' #=> 1970-04-26 17:46:40 UTC
  #
  def self.time(ulid)
    Identifier.new(ulid).time
  end

  # Get the first possible ULID string for the given time in sort order ascending.
  #
  # @param at_time [Time] a Time value to encode in the ULID
  # @return [String] the lexicographically minimum ULID value for the given time
  #
  # @example Get minimal ULID at time
  #   ULID.min_ulid_at Time.at(1_000_000) #=> "0000XSNJG00000000000000000"
  #
  def self.min_ulid_at(at_time)
    Identifier.new(at_time, MIN_ENTROPY).ulid
  end

  # Get the first possible ULID string for the given time in sort order descending.
  #
  # @param at_time [Time] a Time value to encode in the ULID
  # @return [String] the lexicographically maximum ULID value for the given time
  #
  # @example Get minimal ULID at time
  #   ULID.max_ulid_at Time.at(1_000_000) #=> "0000XSNJG0ZZZZZZZZZZZZZZZZ"
  #
  def self.max_ulid_at(at_time)
    Identifier.new(at_time, MAX_ENTROPY).ulid
  end

end
