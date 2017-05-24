require 'ulid/constants'

module ULID
  module Parse
    include Constants

    # v should be a Base32 encoded ULID string. This method decodes it into a
    # 16 byte raw ULID with 48 bit time and 64 bit random parts.
    def decode(v)
      out = []

      # hand optimized, unrolled ULID-Base32 format decoder based on
      # https://github.com/oklog/ulid/blob/c3c01856f7e43fa64133819126887124d5f05e39/ulid.go#L234

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
      time_bytes = packed_bytes[0..5].bytes.map(&:to_i)
      seed = packed_bytes[6..-1]

      # and unpack it immedieately into the original milliseconds timestamp
      # via https://github.com/oklog/ulid/blob/c3c01856f7e43fa64133819126887124d5f05e39/ulid.go#L265
      time_int = time_bytes[5].to_i |
        (time_bytes[4].to_i << 8) |
        (time_bytes[3].to_i << 16) |
        (time_bytes[2].to_i << 24) |
        (time_bytes[1].to_i << 32) |
        (time_bytes[0].to_i << 40)

      [ Time.at( time_int * 0.001 ).utc, seed ]
    end

  end
end
