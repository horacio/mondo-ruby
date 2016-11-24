require 'active_support/hash_with_indifferent_access'
require 'factory_girl'
require 'rspec'
require 'webmock/rspec'
require './lib/mondo'

require_relative 'support/factory_girl'
require_relative 'support/fake_mondo'
require_relative 'support/shared_contexts/client_setup'

RSpec.configure do |config|
  config.expect_with :rspec do |e|
    e.syntax = :expect
  end

  config.mock_with :rspec do |m|
    m.verify_doubled_constant_names = true
  end
end
