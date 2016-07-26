# Capistrano::Rails::Toolbox
some common cap tasks used in projects

## Installation

Add this to your Gemfile:

```ruby
group :development do
  gem 'capistrano-rails-toolbox', git: 'https://github.com/AdaChina/capistrano-rails-toolbox'
end
```

Then execute

```bash
bundle install
```

Add this to your `Capfile`
```ruby
require 'capistrano/rails/toolbox'
```

## Usage

to see what tasks this gem provides:
```bash
bundle exec cap -T
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
