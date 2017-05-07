$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'sequence_diagram/version'

Gem::Specification.new do |s|
  s.name        = 'sequence_diagram'
  s.version     = SequenceDiagram::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['James Mead']
  s.homepage    = 'http://github.com/floehopper/sequence_diagram'
  s.summary     = "sequence_diagram-#{SequenceDiagram::Version::STRING}"
  s.description = 'Generate sequence diagrams by tracing method execution'

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += ['LICENSE.md']
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'

  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rspec'
end
