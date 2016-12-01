source 'https://rubygems.org'

gem 'chef', '~> 12.5'
gem 'ohai', '~> 8.4'

group :lint do
  gem 'foodcritic', '~> 6.0'
  gem 'rainbow', '< 2.0'
  gem 'rspec'
  gem 'rubocop', '~> 0.38'
end

group :packaging do
  gem 'stove'
end

group :unit do
  gem 'berkshelf', '~> 4.2'
  gem 'chefspec', '~> 4.2'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.2'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.11'
end

group :kitchen_cloud do
  gem 'kitchen-ec2'
end

group :development do
  gem 'fauxhai'
  gem 'growl'
  gem 'guard', '~> 2.4'
  gem 'guard-kitchen'
  # gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'pry-nav'
  gem 'rake'
  gem 'rb-fsevent'
  gem 'ruby_gntp'
end
