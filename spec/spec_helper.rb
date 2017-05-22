require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
end

# Require all our libraries
Dir['libraries/*_helper.rb'].each { |f| require File.expand_path(f) }

at_exit { ChefSpec::Coverage.report! }
