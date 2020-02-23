module FixtureHelper
  def fixture(name)
    File.read(fixture_path(name))
  end

  def fixture_path(name)
    File.expand_path(name, fixtures_dir)
  end

  def fixtures_dir
    File.expand_path("../concept_fixtures", __dir__)
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
end
