# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-airtable-import"
  spec.version       = "0.1.7"
  spec.authors       = ["joe-irving"]
  spec.email         = ["joe@irving.me.uk"]

  spec.summary       = "A simple importer from airtable, to collections or data"
  spec.homepage      = "https://github.com/tippingpointuk/jekyll-airtable-import/"
  spec.license       = "MIT"

  spec.files         = %w(Gemfile README.md LICENSE.txt) + Dir["lib/**/*"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_runtime_dependency "jekyll", ">= 3.7", "< 5.0"

  spec.add_runtime_dependency "airtable", "~> 0.0.9"
  spec.add_runtime_dependency "activesupport", "~> 6.1"
  spec.add_runtime_dependency "dotenv", ">=2.8", "<3.0"
end
