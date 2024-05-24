# frozen_string_literal: true

module ULID
  module Compare
    def >(other)
      case other
      when self.class
        ulid > other.ulid
      when Time
        time > other
      when String
        ulid > other
      end
    end

    def <(other)
      case other
      when self.class
        ulid < other.ulid
      when Time
        time < other
      when String
        ulid < other
      end
    end

    def <=>(other)
      case other
      when self.class
        ulid <=> other.ulid
      when Time
        time <=> other
      when String
        ulid <=> other
      end
    end
  end
end
