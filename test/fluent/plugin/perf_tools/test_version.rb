# frozen_string_literal: true

require "helper"

require "fluent/plugin/perf_tools/version"

# unit test for gem version
class VersionTest < Test::Unit::TestCase
  test "it has version" do
    assert Fluent::Plugin::PerfTools::VERSION
  end
end
