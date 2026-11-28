# frozen_string_literal: true

module Astronoby
  # @api private
  module Deprecation
    REMOVAL_VERSION = "0.14.0"
    NESTED_KEY = :astronoby_deprecated_call

    @warned = {}

    def self.warn(owner, name, uplevel: 1, instead: "Astronoby::Sky")
      warned = (@warned[owner] ||= {})
      return if warned.key?(name) || Thread.current[NESTED_KEY]

      warned[name] = true
      subject, replacement = yield
      Kernel.warn(
        "#{subject} is deprecated and will be removed in Astronoby " \
        "#{REMOVAL_VERSION}, use #{instead} instead: #{replacement}",
        uplevel: uplevel + 1
      )
    end

    def self.nested
      previous = Thread.current[NESTED_KEY]
      Thread.current[NESTED_KEY] = true
      yield
    ensure
      Thread.current[NESTED_KEY] = previous
    end

    def self.reset
      @warned.clear
    end
  end
end
