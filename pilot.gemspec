# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pilot/version"

Gem::Specification.new do |s|
  s.name        = "pilot"
  s.version     = Pilot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Roberto Thais"]
  s.email       = ["roberto.n.thais@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/pilot"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "pilot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
