RSpec::Matchers.define :each do |meta|
  match do |actual|
    actual.each_with_index do |i, j|
      @elem = j
      i.should meta
    end
  end

  failure_message_for_should do |actual|
    "at[#{@elem}] #{meta.failure_message_for_should}"
  end
end
