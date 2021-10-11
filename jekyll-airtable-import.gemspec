# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-airtable-import"
  spec.version       = "0.1.0"
  spec.authors       = ["joe-irving"]
  spec.email         = ["joe@irving.me.uk"]

  spec.summary       = "A simple importer from airtable, to collections or data"
  spec.homepage      = "https://tippingpointuk.github.io/jekyll-airtable-import"
  spec.license       = "MIT"

  spec.files         = ["lib/jekyll-airtable-import.rb"]

  spec.add_runtime_dependency "jekyll", "~> 4.2"
  spec.add_runtime_dependency "airtable", "~> 0.0.9"
  spec.add_runtime_dependency "activesupport", "~> 6.1"
end
