# frozen_string_literal: true

require_relative "lib/activemerchant_payrix/version"

Gem::Specification.new do |spec|
  spec.name = "activemerchant_payrix"
  spec.version = ActivemerchantPayrix::VERSION
  spec.authors = ["Printavo Engineers"]

  spec.summary = "An implementation of the ActiveMerchant Gateway API for processing payments via Payrix."
  spec.description = "An implementation of the ActiveMerchant Gateway API for processing payments and associated transactions via the Payrix payment processing platform."
  spec.homepage = "https://www.printavo.com"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Printavo/activemerchant_payrix"
  spec.required_ruby_version = ">= 3.2.2"

  # spec.metadata["allowed_push_host"] = "TODO: Set to our gem server if/when we publish it"
  # spec.metadata["changelog_uri"] = "TODO: Put our gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Our dependencies
  spec.add_dependency "activemerchant", "~> 1.126"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "vcr", "~> 6.1"

  # Guide and more gemspec details here: https://bundler.io/guides/creating_gem.html
end
