module ULID
  module Compare
    def >(other)
      case other
      when self.class
        self.ulid > other.ulid
      when Time
        self.time > other
      when String
        self.ulid > other
      end
    end

    def <(other)
      case other
      when self.class
        self.ulid < other.ulid
      when Time
        self.time < other
      when String
        self.ulid < other
      end
    end

    def <=>(other)
      case other
      when self.class
        self.ulid <=> other.ulid
      when Time
        self.time <=> other
      when String
        self.ulid <=> other
      end
    end
  end
end
