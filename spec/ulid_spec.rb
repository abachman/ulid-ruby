require "spec_helper"

#               time      seed
#               --------------------------
#               0DHWZ1DT60
#                         60ZVCSJFXBTG0J2N
KNOWN_STRING = '0DHWZ1DT6060ZVCSJFXBTG0J2N'
KNOWN_TIME = Time.parse("2017-03-30T15:21:57.318Z")

describe ULID do
  it "has a version number" do
    expect(ULID::VERSION).not_to be nil
  end

  describe '.generate' do
    it "produces ULID strings" do
      expect(ULID.generate).to be_a_valid_ulid
    end
  end

  describe '.at' do

    it 'produces randomized ULID strings for a given time' do
      expect(ULID.at(KNOWN_TIME)).to be_a_valid_ulid
    end

  end

  describe '.time' do
    let(:ulid_time) { ULID.time(KNOWN_STRING) }

    it 'returns Time object' do
      expect(ulid_time).to be_instance_of(Time)
    end

    it 'returns same time that was used to generate it' do
      # NOTE: we may not get the PRECISE time out due to conversion from Time -> Float -> Base32 -> Float -> Time
      expect(ulid_time).to be_within(0.0001).of(KNOWN_TIME)
    end
  end

  describe '.min_ulid_at' do
    let(:ulid_string) { ULID.min_ulid_at(KNOWN_TIME) }

    it 'generates a valid ULID string' do
      expect(ulid_string).to be_a_valid_ulid
      expect(ulid_string).to be_instance_of(String)
    end

    it 'generates the lowest lexicographical ULID' do
      expect(ulid_string).to match(/0000000000000000$/)
    end
  end

  describe '.max_ulid_at' do
    let(:ulid_string) { ULID.max_ulid_at(KNOWN_TIME) }

    it 'generates a valid ULID string' do
      expect(ulid_string).to be_a_valid_ulid
      expect(ulid_string).to be_instance_of(String)
    end

    it 'generates the highest lexicographical ULID' do
      expect(ulid_string).to match(/ZZZZZZZZZZZZZZZZ$/)
    end
  end

  describe ULID::Identifier do
    context 'with no args' do
      it 'generates a random value for the current time' do
        right_now = Time.now
        ulid = ULID::Identifier.new

        expect(ulid.ulid).to be_instance_of(String)
        expect(ulid.ulid).to be_a_valid_ulid
        expect(ulid.time).to be_within(0.0001).of(right_now)
      end
    end
  end

end
