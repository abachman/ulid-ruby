require 'ulid/parse'
require 'ulid/generate'
require 'ulid/compare'

module ULID
  class Identifier
    include Parse
    include Generate
    include Compare

    attr_reader :seed, :bytes, :time, :ulid

    # Create a new instance of a ULID::Identifier.
    #
    # @param start [ULID::Instance, String, Time, or nil] if ULID instance or
    #   string is given, initialize to the exact same value. If Time is given,
    #   generate a new ULID for that time, if no argument is given, generate a
    #   new ULID at the current system time.
    # @param seed [String or nil] a 10-byte, Encoding::ASCII_8BIT encoded string.
    #   The easiest way to generate a seed is to call SecureRandom.random_bytes(10)
    # @return [ULID::Identifier]
    def initialize(start = nil, seed = nil)
      case start
      when self.class
        @time = start.time
        @seed = start.seed
      when NilClass, Time
        @time = start || Time.now
        if seed.nil?
          @seed = random_bytes
        else
          if seed.size != 10 || seed.encoding != Encoding::ASCII_8BIT
            raise ArgumentError.new("seed error, seed value must be 10 bytes encoded as Encoding::ASCII_8BIT")
          end

          @seed = seed
        end
      when String
        if start.size != 26
          raise ArgumentError.new("invalid ULID string, must be 26 characters")
        end

        # parse string into bytes
        @ulid = start.upcase
        @bytes = decode32(@ulid)

        @time, @seed = unpack_decoded_bytes(@bytes)
      else
        # unrecognized initial values type given, just generate fresh ULID
        @time = Time.now
        @seed = random_bytes
      end

      if @bytes.nil?
        # an ASCII_8BIT encoded string, should be 16 bytes
        @bytes = time_bytes + @seed
      end

      if @ulid.nil?
        # the lexically sortable Base32 string we actually care about
        @ulid = encode32
      end
    end
  end
end
