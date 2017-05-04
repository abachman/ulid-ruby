module ULID
  module Constants
    # smallest representable time
    MIN_TIME = ([0] * 6).pack('C' * 6)
    # largest representable time
    MAX_TIME = ([255] * 6).pack('C' * 6)

    # smallest possible seed value
    MIN_ENTROPY = ([0] * 10).pack('C' * 10)
    # largest possible seed value
    MAX_ENTROPY = ([255] * 10).pack('C' * 10)

    # Crockford's Base32. Alphabet portion is missing I, L, O, and U.
    ENCODING = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

    # Byte to index table for O(1) lookups when unmarshaling.
    # We rely on nil as sentinel value for invalid indexes.
    B32REF = Hash[ ENCODING.split('').each_with_index.to_a ]
  end
end

