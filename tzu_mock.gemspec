require_relative "lib/tzu_mock/version"

Gem::Specification.new do |s|
  s.name = "tzu_mock"
  s.version = TzuMock::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Blake Turner"]
  s.description = "Simple library for mocking Tzu in RSpec"
  s.summary = "TDD with Tzu!"
  s.email = "mail@blakewilliamturner.com"
  s.homepage = "https://github.com/onfido/tzu_mock"
  s.license = "MIT"

  s.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  s.require_paths = ["lib"]

  s.add_dependency "binding_of_caller", ">= 0.7"
  s.add_dependency "hashie", "~> 3"
  s.add_dependency "tzu"
  s.add_dependency "rspec"
end
