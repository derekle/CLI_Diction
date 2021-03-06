require_relative './lib/CLI_Diction/version'

Gem::Specification.new do |s|
  s.name        = 'CLI_Diction'
  s.version     = Diction::VERSION
  s.date        = '2021-03-06'
  s.summary     = "Text information"
  s.description = "Retrieves information for user input text via Datamuse"
  s.authors     = ["Derek Le"]
  s.email       = 'derekle.creative@gmail.com'
  s.files       = ["lib/CLI_Diction.rb", "lib/CLI_Diction/cli.rb", "lib/CLI_Diction/scraper.rb", "lib/CLI_Diction/app.rb", "config/environment.rb"]
  s.license     = 'MIT'
  s.homepage    = 'https://rubygems.org/gems/CLI_Diction'
  s.executables << 'CLI_Diction'

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_dependency "rake", "~> 12.3.3"
  s.add_development_dependency "rspec", "~> 0"
  s.add_development_dependency 'rubymuse', '~> 0.1.3'
end