# frozen_string_literal: true

module ULID
  module Constants
    # smallest representable time
    MIN_TIME = ([0] * 6).pack("C" * 6)
    # largest representable time
    MAX_TIME = ([255] * 6).pack("C" * 6)

    # smallest possible seed value
    MIN_ENTROPY = ([0] * 10).pack("C" * 10)
    # largest possible seed value
    MAX_ENTROPY = ([255] * 10).pack("C" * 10)

    # Crockford's Base32 (https://www.crockford.com/base32.html) Differs from Base32 in the following ways:
    # * Excludes I, L, O and U
    # * Aliases O to 0
    # * Aliases I and L to 1
    # * Uses U * ~ $ and = for appended checksums
    #
    # For simplicity, we use the RFC4648 Base32 encoding and convert to Crockford's Base32 with a simple translate
    # However, we aren't supporting checksums nor the aliased characters
    #
    # B32_CROCKFORD_CHARS = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
    # B32_RCF4648_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUV"

    B32_CROCKFORD_FRAGMENT = "JKMNPQRSTVWXYZ".upcase.freeze
    B32_RCF4648_FRAGMENT = "IJKLMNOPQRSTUV".downcase.freeze # forcing downcase becase .to_s(32) is always lowercase
  end
end
