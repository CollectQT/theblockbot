require 'flt'
require 'json'
require 'hash_dot'

require 'vcr_helper'
require 'login_helper'
require 'factory_helper'
require 'sidekiq_helper'


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
