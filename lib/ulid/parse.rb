# frozen_string_literal: true

require 'ulid/constants'

module ULID
  module Parse
    include Constants

    # v should be a Base32 encoded ULID string. This method decodes it into a
    # 16 byte raw ULID with 48 bit time and 64 bit random parts.
    def decode32(input)
      value = Integer(input.tr(B32_CROCKFORD_FRAGMENT, B32_RCF4648_FRAGMENT).downcase, 32)
      [value >> 64, value & 0xFFFFFFFFFFFFFFFF].pack("Q>Q>")
    end

    def unpack_ulid_bytes(packed_bytes)
      time_int, _ = ("\x00\x00" + packed_bytes).unpack("Q>")
      seed = packed_bytes[6..-1]

      [Time.at(time_int.to_f / 1000.0), seed]
    end
  end
end
