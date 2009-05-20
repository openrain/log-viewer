# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bong-log-viewer}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["remi"]
  s.date = %q{2009-05-20}
  s.default_executable = %q{bong-log-viewer}
  s.description = %q{Sinatra application for viewing/comparing logs created by http://github.com/topfunky/bong}
  s.email = %q{remi@remitaylor.com}
  s.executables = ["bong-log-viewer"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/bong-log-viewer",
     "lib/bong-log-viewer.rb"
  ]
  s.homepage = %q{http://github.com/remi/bong-log-viewer}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Sinatra application for viewing/comparing logs created by bong}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
