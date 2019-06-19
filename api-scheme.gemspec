# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api/scheme"

Gem::Specification.new do |spec|
  spec.name          = "api-scheme"
  spec.version       = Api::Scheme::VERSION
  spec.authors       = ["Malo Skrylevo"]
  spec.email         = ["majioa@yandex.ru"]

  spec.summary       = %q{API Scheme for Rails Action Controller}
  spec.description   = %q{Provides simple error handling and param processing scheme
                          to make API and other actions for Rail Action Controller. This version
                          obsoletes \`rails-api-scheme` gem}
  spec.homepage      = "https://github.com/majioa/rails-api-scheme"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
