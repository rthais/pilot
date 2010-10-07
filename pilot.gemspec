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
  s.summary     = %q{Association powered file attachments}
  s.description = %q{Coming soon!}

  s.rubyforge_project = "pilot"
  
  s.requirements << "ImageMagick"
  
  s.add_dependency "mini_magick", "~> 2.1"
  s.add_dependency "fog", "~> 0.3.7"
  s.add_dependency "activesupport", "~> 3.0"
  s.add_dependency "activerecord",  "~> 3.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
