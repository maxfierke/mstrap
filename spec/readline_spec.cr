require "./spec_helper"

describe Readline do
  typeof(Readline.readline)
  typeof(Readline.readline("Hello", true))
  typeof(Readline.readline(prompt: "Hello"))
  typeof(Readline.readline(add_history: false))
  typeof(Readline.line_buffer)
  typeof(Readline.point)
  typeof(Readline.autocomplete { |s| %w(foo bar) })

  it "gets prefix in bytesize between two strings" do
    expect(Readline.common_prefix_bytesize("", "foo")).must_equal(0)
    expect(Readline.common_prefix_bytesize("foo", "")).must_equal(0)
    expect(Readline.common_prefix_bytesize("a", "a")).must_equal(1)
    expect(Readline.common_prefix_bytesize("open", "operate")).must_equal(3)
    expect(Readline.common_prefix_bytesize("operate", "open")).must_equal(3)
    expect(Readline.common_prefix_bytesize(["operate", "open", "optional"])).must_equal(2)
  end
end
