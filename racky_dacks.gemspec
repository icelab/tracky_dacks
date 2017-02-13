lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "racky_dacks/version"

Gem::Specification.new do |spec|
  spec.name          = "racky_dacks"
  spec.version       = RackyDacks::VERSION
  spec.authors       = ["Dylan Wolff", "Tim Riley"]
  spec.email         = ["dylan.wolff@icelab.com.au", "tim@icelab.com.au"]

  spec.summary       = "Server-side Google Analytics tracking and redirects"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/icelab/racky_dacks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "staccato"
  spec.add_runtime_dependency "sucker_punch"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
