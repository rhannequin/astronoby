# frozen_string_literal: true

require_relative "lib/astronoby/version"

Gem::Specification.new do |spec|
  spec.name = "astronoby"
  spec.version = Astronoby::VERSION
  spec.authors = ["Rémy Hannequin"]
  spec.email = ["hello@rhannequ.in"]

  spec.summary = "Astronomical calculations"
  spec.description = "Ruby version of the calculations from various books like Celestial Calculations by J. L. Lawrence, Practical Astronomy with your Calculator or Spreadsheet by Peter Duffett-Smith and Jonathan Zwart, or Astronomical Algorithms by Jean Meeus"
  spec.homepage = "https://github.com/rhannequin/astronoby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "matrix", "~> 0.4.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubyzip", "~> 2.3"
  spec.add_development_dependency "standard", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
