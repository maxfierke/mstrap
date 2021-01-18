require "./spec_helper"

Spectator.describe Readline do
  typeof(Readline.readline)
  typeof(Readline.readline("Hello", true))
  typeof(Readline.readline(prompt: "Hello"))
  typeof(Readline.readline(add_history: false))
  typeof(Readline.line_buffer)
  typeof(Readline.point)
  typeof(Readline.autocomplete { |s| %w(foo bar) })

  it "gets prefix in bytesize between two strings" do
    expect(Readline.common_prefix_bytesize("", "foo")).to eq(0)
    expect(Readline.common_prefix_bytesize("foo", "")).to eq(0)
    expect(Readline.common_prefix_bytesize("a", "a")).to eq(1)
    expect(Readline.common_prefix_bytesize("open", "operate")).to eq(3)
    expect(Readline.common_prefix_bytesize("operate", "open")).to eq(3)
    expect(Readline.common_prefix_bytesize(["operate", "open", "optional"])).to eq(2)
  end
end
