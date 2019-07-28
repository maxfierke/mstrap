require "file_utils"
require "minitest/autorun"

MSTRAP_TEST_HOME = File.expand_path("tmp/test-home")
FileUtils.rm_rf(MSTRAP_TEST_HOME)
Dir.mkdir_p(MSTRAP_TEST_HOME)
ENV["HOME"] = MSTRAP_TEST_HOME

require "../src/mstrap"
