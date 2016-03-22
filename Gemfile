source 'https://rubygems.org'

gem 'ohai', '~> 8.4'
gem 'chef', '~> 12.5'

group :lint do
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop', '~> 0.38'
  gem 'rainbow', '< 2.0'
  gem 'rspec'
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
  gem 'ruby_gntp'
  gem 'growl'
  gem 'rb-fsevent'
  gem 'guard', '~> 2.4'
  gem 'guard-kitchen'
  # gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rake'
  gem 'fauxhai'
  gem 'pry-nav'
end
