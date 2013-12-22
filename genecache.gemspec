# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'genecache/version'

Gem::Specification.new do |spec|
  spec.name          = "genecache"
  spec.version       = Genecache::VERSION
  spec.authors       = ["Fedor Gusev"]
  spec.email         = ["gusevfe@gmail.com"]
  spec.description   = %q{Very simple GENE ID conversion tool with a local SQLite3 DB for caching}
  spec.summary       = %q{Simple and fast conversion of GENE IDs. Major source of data is http://biodb.jp. Conversion tables are downloaded and stored in local SQLite database for very fast access.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'sqlite3'
  spec.add_dependency 'zipruby'
end
