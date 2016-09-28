# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rust_watcher/version'

Gem::Specification.new do |spec|
  spec.name          = "rust_watcher"
  spec.version       = RustWatcher::VERSION
  spec.authors       = ["Dave Allie"]
  spec.email         = ["dave@daveallie.com"]

  spec.summary       = %q{Ruby bindings for rsnotify.}
  spec.description   = %q{Ruby bindings for rsnotify, a cross-platform file watching utility written in Rust.}
  spec.homepage      = "https://github.com/daveallie/rust_watcher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extensions << 'ext/Rakefile'
  spec.add_runtime_dependency 'thermite', '~> 0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
