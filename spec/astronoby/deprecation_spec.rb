# frozen_string_literal: true

RSpec.describe Astronoby::Deprecation, :deprecations do
  describe "::warn" do
    it "warns once per entry point, at the caller's line" do
      owner = Class.new

      expect {
        2.times do
          described_class.warn(owner, :call, uplevel: 0) do
            ["Old#call", "sky.new_call"]
          end
        end
      }.to output(
        "#{__FILE__}:#{__LINE__ - 5}: warning: Old#call is deprecated and " \
        "will be removed in Astronoby 0.14.0, use Astronoby::Sky instead: " \
        "sky.new_call\n"
      ).to_stderr
    end

    it "warns again for another entry point of the same owner" do
      owner = Class.new

      expect {
        described_class.warn(owner, :first) { ["Old#first", "sky.first"] }
        described_class.warn(owner, :second) { ["Old#second", "sky.second"] }
      }.to output(/Old#first.*\n.*Old#second/).to_stderr
    end

    it "stays silent inside another deprecated call" do
      owner = Class.new

      expect {
        described_class.nested do
          described_class.warn(owner, :call) { ["Old#call", "sky.call"] }
        end
      }.not_to output.to_stderr
    end
  end
end
