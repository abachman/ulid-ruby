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
#   ulid.time
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

class ULID
  ENCODING = "0123456789ABCDEFGHJKMNPQRSTVWXYZ" # Crockford's Base32
  RANDOM_BYTES = 10

  MIN_TIME = ([0] * 6).pack('C' * 6)
  MAX_TIME = ([255] * 6).pack('C' * 6)

  MIN_ENTROPY = ([0] * 10).pack('C' * 10)
  MAX_ENTROPY = ([255] * 10).pack('C' * 10)

  # Byte to index table for O(1) lookups when unmarshaling.
  # We use nil as sentinel value for invalid indexes.
  B32REF = Hash[ ENCODING.split('').each_with_index.to_a ]

  attr_reader :seed, :bytes, :time, :ulid

  ## helpers for generating and parsing ULID strings

  def self.generate
    new.ulid
  end

  # takes Time object, returns ULID string
  def self.at(at_time)
    new(at_time).ulid
  end

  # takes ULID string, returns UTC Time object
  def self.time(ulid)
    new(ulid).time.utc
  end

  ## helpers for querying ULID values in a data store

  def self.min_ulid_at(at_time)
    new(at_time, MIN_ENTROPY).ulid
  end

  def self.max_ulid_at(at_time)
    new(at_time, MAX_ENTROPY).ulid
  end

  ##

  def initialize(start = nil, seed = nil)
    case start
    when self.class
      @time = start.time.utc
      @seed = start.seed
    when NilClass, Time
      @time = (start || Time.now).utc
      if seed == nil
        @seed = random_bytes
      else
        if seed.size != 10 || seed.encoding != Encoding::ASCII_8BIT
          raise "seed error, seed value must be 10 bytes encoded as Encoding::ASCII_8BIT"
        end
        @seed = seed
      end
    when String
      if start.size != 26
        raise "invalid ULID, must be 26 characters"
      end

      # parse string into bytes
      @ulid = start
      @bytes = decode(@ulid)

      @time, @seed = unpack_decoded_bytes(@bytes)
    else
      # unrecognized initial values type given, just generate fresh ULID

      @time = Time.now.utc
      @seed = random_bytes
    end

    if @bytes.nil?
      # an ASCII_8BIT encoded string, should be 16 bytes
      @bytes = time_48bit + @seed
    end

    if @ulid.nil?
      # the lexically sortable Base32 string we actually care about
      @ulid = encode32
    end
  end

  def >(other)
    case other
    when self.class
      self.ulid > other.ulid
    when Time
      self.time > other
    when String
      self.ulid > other
    end
  end

  def <(other)
    case other
    when self.class
      self.ulid < other.ulid
    when Time
      self.time < other
    when String
      self.ulid < other
    end
  end

  def <=>(other)
    case other
    when self.class
      self.ulid <=> other.ulid
    when Time
      self.time <=> other
    when String
      self.ulid <=> other
    end
  end

  private

  # encode32 returns the binary ULID as Base32 encoded string.
  def encode32
    # Optimized unrolled loop ahead.
    # From https://github.com/RobThree/NUlid
    # via https://github.com/oklog/ulid/blob/master/ulid.go#L154

    id = @bytes.bytes

    output = ''

    # Base32 encodes 5 bits of each byte of the input in each byte of the
    # output. That means each input byte produces >1 output byte and some
    # output bytes encode parts of multiple input bytes.
    #
    # The end result is a human / URL friendly output string that can be
    # decoded into the original bytes.

    # 10 byte timestamp
    output << ENCODING[(id[0]&224)>>5]
    output << ENCODING[id[0]&31]
    output << ENCODING[(id[1]&248)>>3]
    output << ENCODING[((id[1]&7)<<2)|((id[2]&192)>>6)]
    output << ENCODING[(id[2]&62)>>1]
    output << ENCODING[((id[2]&1)<<4)|((id[3]&240)>>4)]
    output << ENCODING[((id[3]&15)<<1)|((id[4]&128)>>7)]
    output << ENCODING[(id[4]&124)>>2]
    output << ENCODING[((id[4]&3)<<3)|((id[5]&224)>>5)]
    output << ENCODING[id[5]&31]

    # 16 bytes of entropy
    output << ENCODING[(id[6]&248)>>3]
    output << ENCODING[((id[6]&7)<<2)|((id[7]&192)>>6)]
    output << ENCODING[(id[7]&62)>>1]
    output << ENCODING[((id[7]&1)<<4)|((id[8]&240)>>4)]
    output << ENCODING[((id[8]&15)<<1)|((id[9]&128)>>7)]
    output << ENCODING[(id[9]&124)>>2]
    output << ENCODING[((id[9]&3)<<3)|((id[10]&224)>>5)]
    output << ENCODING[id[10]&31]
    output << ENCODING[(id[11]&248)>>3]
    output << ENCODING[((id[11]&7)<<2)|((id[12]&192)>>6)]
    output << ENCODING[(id[12]&62)>>1]
    output << ENCODING[((id[12]&1)<<4)|((id[13]&240)>>4)]
    output << ENCODING[((id[13]&15)<<1)|((id[14]&128)>>7)]
    output << ENCODING[(id[14]&124)>>2]
    output << ENCODING[((id[14]&3)<<3)|((id[15]&224)>>5)]
    output << ENCODING[id[15]&31]

    output
  end

  # v is Base32 encoded ULID string, decode into 16 byte raw ULID with 48 bit
  # time and 64 bit random parts>
  def decode(v)
    out = []

    # hand optimized, unrolled ULID-Base32 format decoder based on
    # https://github.com/oklog/ulid/blob/master/ulid.go#L234

    # 6 bytes timestamp (48 bits)
    out << ((B32REF[v[0]] << 5) |  B32REF[v[1]])
    out << ((B32REF[v[2]] << 3) | (B32REF[v[3]] >> 2))
    out << ((B32REF[v[3]] << 6) | (B32REF[v[4]] << 1) | (B32REF[v[5]] >> 4))
    out << ((B32REF[v[5]] << 4) | (B32REF[v[6]] >> 1))
    out << ((B32REF[v[6]] << 7) | (B32REF[v[7]] << 2) | (B32REF[v[8]] >> 3))
    out << ((B32REF[v[8]] << 5) |  B32REF[v[9]])

    # 10 bytes of entropy (80 bits)
    out << ((B32REF[v[10]] << 3) | (B32REF[v[11]] >> 2))
    out << ((B32REF[v[11]] << 6) | (B32REF[v[12]] << 1) | (B32REF[v[13]] >> 4))
    out << ((B32REF[v[13]] << 4) | (B32REF[v[14]] >> 1))
    out << ((B32REF[v[14]] << 7) | (B32REF[v[15]] << 2) | (B32REF[v[16]] >> 3))
    out << ((B32REF[v[16]] << 5) | B32REF[v[17]])
    out << ((B32REF[v[18]] << 3) | B32REF[v[19]]>>2)
    out << ((B32REF[v[19]] << 6) | (B32REF[v[20]] << 1) | (B32REF[v[21]] >> 4))
    out << ((B32REF[v[21]] << 4) | (B32REF[v[22]] >> 1))
    out << ((B32REF[v[22]] << 7) | (B32REF[v[23]] << 2) | (B32REF[v[24]] >> 3))
    out << ((B32REF[v[24]] << 5) | B32REF[v[25]])

    # get the array as a string, coercing each value to a single byte
    out = out.pack('C' * 16)

    out
  end

  def unpack_decoded_bytes(packed_bytes)
    time_bytes = packed_bytes[0..5]
    seed = packed_bytes[6..-1]

    # and unpack it immedieately into the original milliseconds timestamp
    time_int = ("\x00\x00" + time_bytes).unpack('Q>')[0]

    [ Time.at( time_int / 10_000.0 ).utc, seed ]
  end

  def random_bytes
    seed = SecureRandom.random_bytes(10)
  end

  def hundred_micro_time
    (@time.to_f * 10_000).to_i
  end

  def time_48bit
    [hundred_micro_time].pack("Q>")[2..-1]
  end
end

