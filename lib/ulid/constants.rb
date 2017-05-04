module ULID
  module Constants
    RANDOM_BYTES = 10

    MIN_TIME = ([0] * 6).pack('C' * 6)
    MAX_TIME = ([255] * 6).pack('C' * 6)

    MIN_ENTROPY = ([0] * 10).pack('C' * 10)
    MAX_ENTROPY = ([255] * 10).pack('C' * 10)

    # Crockford's Base32. Alphabet portion is missing I, L, O, and U.
    ENCODING = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

    # Byte to index table for O(1) lookups when unmarshaling.
    # We rely on nil as sentinel value for invalid indexes.
    B32REF = Hash[ ENCODING.split('').each_with_index.to_a ]
  end
end

