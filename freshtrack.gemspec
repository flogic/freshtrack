Gem::Specification.new do |gem|
  gem.add_development_dependency 'bacon', '>= 1.1.0'
  gem.add_development_dependency 'facon', '>= 0.5.0'
  gem.add_runtime_dependency 'freshbooks', '= 2.1'
  gem.authors = ['Yossef Mendelssohn']
  gem.description = %q{A simple tool to take your locally-tracked time and put it up on FreshBooks.}
  gem.email = ['ymendel@pobox.com']
  gem.executables = ['freshtrack']
  gem.files = Dir['License.txt', 'History.txt', 'README.txt', 'lib/**/*', 'spec/**/*', 'bin/**/*']
  gem.homepage = 'http://github.com/flogic/freshtrack/'
  gem.name = 'freshtrack'
  gem.require_paths = ['lib']
  gem.summary = %q{Track your time on FreshBooks}
  gem.version = '0.6.0'
end
