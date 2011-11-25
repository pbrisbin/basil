# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "basil/version"

Gem::Specification.new do |s|
  s.name        = "basil"
  s.version     = Basil::VERSION
  s.authors     = ["patrick brisbin"]
  s.email       = ["pbrisbin@gmail.com"]
  s.homepage    = "http://github.com/pbrisbin/basil"
  s.summary     = "basil is a simple bot"
  s.description = "basil is a simple bot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.licenses      = ["MIT"]

  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "skype"
end
