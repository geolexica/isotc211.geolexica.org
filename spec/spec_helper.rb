require "bundler"
Bundler.require(:default, :development)

Dir[File.expand_path "support/**/*.rb", __dir__].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # This will default to `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3).
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!
end
