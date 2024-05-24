# frozen_string_literal: true

require "spec_helper"

#               time      seed
#               --------------------------
#               0DHWZ1DT60
#                         60ZVCSJFXBTG0J2N
KNOWN_STRING = "01ARYZ6RR0T8CNRGXPSBZSA1PY"
KNOWN_TIME = Time.parse("2016-07-30 22:36:16 UTC")
KNOWN_UUID = "01563df3-6300-d219-5c43-b6caff9506de"
KNOWN_BYTES = "\x01V=\xF3c\x00\xD2\x19\\C\xB6\xCA\xFF\x95\x06\xDE".b
KNOWN_UINT128 = 1777022035688232904178850488005232350

describe ULID do
  it "has a version number" do
    expect(ULID::VERSION).not_to(be(nil))
  end

  describe ".generate" do
    it "produces ULID strings" do
      expect(ULID.generate).to(be_a_valid_ulid)
    end
  end

  describe ".at" do
    it "produces randomized ULID strings for a given time" do
      expect(ULID.at(KNOWN_TIME)).to(be_a_valid_ulid)
    end

    it "handles timestamp as the milliseconds precision" do
      expect(ULID.at(Time.parse("2016-07-30 22:36:16.001000000 UTC"))).to(start_with("01ARYZ6RR1"))
      expect(ULID.at(Time.parse("2016-07-30 22:36:16.002000001 UTC"))).to(start_with("01ARYZ6RR2")) # leap nanosecond
      expect(ULID.at(Time.parse("2016-07-30 22:36:16.003000000 UTC"))).to(start_with("01ARYZ6RR3"))
    end
  end

  describe ".time" do
    let(:ulid_time) { ULID.time(KNOWN_STRING) }

    it "returns Time object" do
      expect(ulid_time).to(be_instance_of(Time))
    end

    it "returns same time that was used to generate it" do
      expect(ulid_time).to(eq(KNOWN_TIME))
    end

    it "handles timestamp as the milliseconds precision" do
      time = ULID.time("0A000000000000000000000000")
      expect(time.to_i).to(eq(10995116277))

      # ULID precision is only to the millisecond value. Some parses will infer leap nanoseconds
      expect(time.nsec).to(be_within(1000).of(760000000))
    end
  end

  describe ".min_ulid_at" do
    let(:ulid_string) { ULID.min_ulid_at(KNOWN_TIME) }

    it "generates a valid ULID string" do
      expect(ulid_string).to(be_a_valid_ulid)
      expect(ulid_string).to(be_instance_of(String))
    end

    it "generates the lowest lexicographical ULID" do
      expect(ulid_string).to(match(/0000000000000000$/))
    end
  end

  describe ".max_ulid_at" do
    let(:ulid_string) { ULID.max_ulid_at(KNOWN_TIME) }

    it "generates a valid ULID string" do
      expect(ulid_string).to(be_a_valid_ulid)
      expect(ulid_string).to(be_instance_of(String))
    end

    it "generates the highest lexicographical ULID" do
      expect(ulid_string).to(match(/ZZZZZZZZZZZZZZZZ$/))
    end
  end

  describe ".uuid" do
    it "generates a valid UUID" do
      ulid = ULID.new(KNOWN_STRING)
      expect(ulid.uuid).to(eq(KNOWN_UUID))
    end
  end

  describe ".bytes" do
    it "from a valid UUID" do
      ulid = ULID.new(KNOWN_UUID)
      expect(ulid.bytes).to(eq(KNOWN_BYTES))
    end
  end

  describe ULID::Identifier do
    context "with no initialization value" do
      it "generates a random value for the current time" do
        right_now = Time.now
        ulid = ULID.new

        expect(ulid.ulid).to(be_instance_of(String))
        expect(ulid.ulid).to(be_a_valid_ulid)
        expect(ulid.time).to(be_within(0.001).of(right_now))
      end
    end

    context "with Time" do
      it "generates a ULID for that time" do
        right_now = Time.now
        ulid = ULID.new(right_now)

        expect(ulid.ulid).to(be_instance_of(String))
        expect(ulid.ulid).to(be_a_valid_ulid)
        expect(ulid.time).to(be_within(0.001).of(right_now))
      end
    end

    context "with ULID::Instance" do
      it "generates the same ULID" do
        first = ULID.new
        other = ULID.new(first)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.time).to(eq(first.time))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
      end
    end

    context "with ULID string arg" do
      it "generates to same ULID" do
        first = ULID.new
        other = ULID.new(first.ulid)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))

        # same caveat as "returns the same time" note above
        expect(other.time).to(be_within(0.001).of(first.time))
      end

      it "generates with lowercase alphabet" do
        first = ULID.new(KNOWN_STRING)
        other = ULID.new(KNOWN_STRING.downcase)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(eq(first.time))
      end

      it "raises an error for invalid ULID string" do
        expect { ULID.new("not a valid ULID!") }.to(raise_error(ArgumentError))
        expect { ULID.new("") }.to(raise_error(ArgumentError))
        expect { ULID.new(KNOWN_STRING + KNOWN_STRING) }.to(raise_error(ArgumentError))
      end
    end

    context "with Bytes string arg" do
      it "supports byteform" do
        first = ULID.new
        other = ULID.new(first.bytes)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(be_within(0.001).of(first.time))
      end
    end

    context "with UUID string arg" do
      it "supports UUID" do
        first = ULID.new(KNOWN_UUID)
        other = ULID.new(KNOWN_STRING)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(eq(first.time))
      end

      it "supports UUID case insensitive" do
        first = ULID.new(KNOWN_UUID.downcase)
        other = ULID.new(KNOWN_UUID.upcase)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(eq(first.time))
      end

      it "supports UUID self generated" do
        first = ULID.new
        other = ULID.new(first.uuid)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(be_within(0.001).of(first.time))
      end
    end

    context "with uInt128 arg" do
      it "supports BigNum" do
        first = ULID.new
        other = ULID.new(first.int128)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(be_within(0.001).of(first.time))
      end

      it "supports BigNum self generated" do
        first = ULID.new(KNOWN_UINT128)
        other = ULID.new(KNOWN_STRING)

        expect(other.ulid).to(eq(first.ulid))
        expect(other.seed).to(eq(first.seed))
        expect(other.bytes).to(eq(first.bytes))
        expect(other.time).to(eq(first.time))
      end
    end

    describe "compared to other ULIDs" do
      let(:at_time) { Time.now }
      let(:first) { ULID.new(at_time - 5) }
      let(:last) { ULID.new(at_time) }

      it "is sortable with <" do
        expect(first).to(be < last)
        expect(first).to(be < last.ulid)
        expect(first).to(be < last.time)
      end

      it "is sortable with >" do
        expect(last).to(be > first)
        expect(last).to(be > first.ulid)
        expect(last).to(be > first.time)
      end

      it "is sortable in a list" do
        reverse = [last, first]
        expect(reverse[0]).not_to(be(first))
        expect(reverse.sort[0]).to(be(first))
      end

      it "sorts the same as strings" do
        # get reverse list of ULID instances
        reverse = [last, first]

        # ... and reversed list of ULID strings
        ulids = [last.ulid, first.ulid]

        ulids.each do |u|
          expect(u).to(be_instance_of(String))
          expect(u).to(be_a_valid_ulid)
        end

        # compare both when sorted
        ulids_sorted = reverse.sort.map(&:ulid)
        strings_sorted = ulids.sort

        ulids_sorted.zip(strings_sorted).each do |(a, b)|
          expect(a).to(eq(b))
        end
      end
    end
  end
end
