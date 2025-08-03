# frozen_string_literal: true

require_relative "lib/astronoby/version"

Gem::Specification.new do |spec|
  spec.name = "astronoby"
  spec.version = Astronoby::VERSION
  spec.authors = ["Rémy Hannequin"]
  spec.email = ["remy.hannequin@gmail.com"]

  spec.summary = "Astronomical calculations"
  spec.description = "Astronomy and astrometry Ruby library for astronomical data and events."
  spec.homepage = "https://github.com/rhannequin/astronoby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(
        *%w[
          benchmarks/
          bin/
          spec/
          .git
          .github
          Gemfile
        ]
      )
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ephem", "~> 0.3"
  spec.add_dependency "matrix", "~> 0.4.2"

  spec.add_development_dependency "benchmark", "~> 0.4"
  spec.add_development_dependency "irb", "~> 1.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubyzip", "~> 2.3"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "standard", "~> 1.3"
end
