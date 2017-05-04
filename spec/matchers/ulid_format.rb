require 'rspec/expectations'

RSpec::Matchers.define :be_a_valid_ulid do
  match do |actual|
    actual =~ /\A[0123456789ABCDEFGHJKMNPQRSTVWXYZ]{26}\z/
  end
end

