$:.push File.expand_path("../lib", __FILE__)

require "vemv/version"

Gem::Specification.new do |s|
  s.name        = "vemv"
  s.version     = Vemv::VERSION
  s.authors     = ["vemv"]
  s.email       = ["vemv@users.noreply.github.com"]
  s.homepage    = "http://www.vemv.net"
  s.summary     = "vemv"
  s.description = "vemv"
  s.license     = "Copyright 2017 Víctor M. Valenzuela"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "rails", "~> 5.0.1"

end
