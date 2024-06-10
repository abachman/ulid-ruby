# frozen_string_literal: true

require 'securerandom'
require 'ulid/constants'

module ULID
  module Generate
    include Constants

    # returns the binary ULID as Base32 encoded string.
    def encode32
      high = bytes.unpack1("Q>")
      low = bytes.unpack1("@8Q>")
      value = (high << 64) | low

      # use the RFC4648 Base32 encoding and convert to Crockford's Base32 with a simple translate
      # assumes that the value is a 128-bit integer
      # also assumes that .to_s(32) is lowercase
      b32 = value.to_s(32)
      b32.tr!(B32_RCF4648_FRAGMENT, B32_CROCKFORD_FRAGMENT)
      b32.upcase!

      return "0#{b32}" if b32.length == 25

      b32
    end

    def random_bytes
      SecureRandom.random_bytes(10)
    end

    # THIS IS CORRECT (to the ULID spec)
    def time_bytes
      epoch_ms = (time.to_f * 1000).to_i
      [epoch_ms].pack("Q>").slice(2, 8)
    end
  end
end
