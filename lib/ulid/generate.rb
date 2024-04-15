require 'securerandom'
require 'ulid/constants'

module ULID

  module Generate
    include Constants

    # returns the binary ULID as Base32 encoded string.
    def encode32
      # Optimized unrolled loop ahead.
      # From https://github.com/RobThree/NUlid
      # via https://github.com/oklog/ulid/blob/c3c01856f7e43fa64133819126887124d5f05e39/ulid.go#L154

      id = @bytes.bytes

      output = ''

      # Base32 encodes 5 bits of each byte of the input in each byte of the
      # output. That means each input byte produces >1 output byte and some
      # output bytes encode parts of multiple input bytes.
      #
      # The end result is a human / URL friendly output string that can be
      # decoded into the original bytes.

      # 10 byte timestamp
      output << ENCODING_LIST[(id[0]&224)>>5]
      output << ENCODING_LIST[id[0]&31]
      output << ENCODING_LIST[(id[1]&248)>>3]
      output << ENCODING_LIST[((id[1]&7)<<2)|((id[2]&192)>>6)]
      output << ENCODING_LIST[(id[2]&62)>>1]
      output << ENCODING_LIST[((id[2]&1)<<4)|((id[3]&240)>>4)]
      output << ENCODING_LIST[((id[3]&15)<<1)|((id[4]&128)>>7)]
      output << ENCODING_LIST[(id[4]&124)>>2]
      output << ENCODING_LIST[((id[4]&3)<<3)|((id[5]&224)>>5)]
      output << ENCODING_LIST[id[5]&31]

      # 16 bytes of entropy
      output << ENCODING_LIST[(id[6]&248)>>3]
      output << ENCODING_LIST[((id[6]&7)<<2)|((id[7]&192)>>6)]
      output << ENCODING_LIST[(id[7]&62)>>1]
      output << ENCODING_LIST[((id[7]&1)<<4)|((id[8]&240)>>4)]
      output << ENCODING_LIST[((id[8]&15)<<1)|((id[9]&128)>>7)]
      output << ENCODING_LIST[(id[9]&124)>>2]
      output << ENCODING_LIST[((id[9]&3)<<3)|((id[10]&224)>>5)]
      output << ENCODING_LIST[id[10]&31]
      output << ENCODING_LIST[(id[11]&248)>>3]
      output << ENCODING_LIST[((id[11]&7)<<2)|((id[12]&192)>>6)]
      output << ENCODING_LIST[(id[12]&62)>>1]
      output << ENCODING_LIST[((id[12]&1)<<4)|((id[13]&240)>>4)]
      output << ENCODING_LIST[((id[13]&15)<<1)|((id[14]&128)>>7)]
      output << ENCODING_LIST[(id[14]&124)>>2]
      output << ENCODING_LIST[((id[14]&3)<<3)|((id[15]&224)>>5)]
      output << ENCODING_LIST[id[15]&31]

      output
    end

    def random_bytes
      SecureRandom.random_bytes(10)
    end

    def millisecond_time
      (@time.to_r * 1_000).to_i
    end

    # THIS IS CORRECT (to the ULID spec)
    def time_bytes
      id = []

      t = millisecond_time

      # via https://github.com/oklog/ulid/blob/c3c01856f7e43fa64133819126887124d5f05e39/ulid.go#L295
      id << [t >> 40].pack('c')
      id << [t >> 32].pack('c')
      id << [t >> 24].pack('c')
      id << [t >> 16].pack('c')
      id << [t >> 8].pack('c')
      id << [t].pack('c')

      id.join
    end
  end
end
