$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "capistrano/rails/toolbox/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "capistrano-rails-toolbox"
  s.version     = Capistrano::Rails::Toolbox::VERSION
  s.authors     = ["ACzero"]
  s.email       = ["lzh.scut@hotmail.com"]
  s.homepage    = "https://github.com/AdaChina/capistrano-rails-toolbox"
  s.summary     = "..."
  s.description = "..."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1"
  s.add_dependency "capistrano", "~> 3.1"
  s.add_dependency "capistrano-rails", "~> 1.1"
  s.add_dependency "sshkit", "~> 1.3"

  s.add_development_dependency "sqlite3"
end
