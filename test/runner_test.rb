# frozen_string_literal: true

require "test_helper"

class RunnerTest < Test
  def setup
    ARGV.clear
  end

  # def test_no_view
  #   assert_output "", "gaapi: You must provide a view ID." do
  #     Main.call
  #   end
  # end

  def test_simple_command_line
    ARGV.concat(%w[-q basic.json -a asldkjfalkdfj --dry-run 888888])
    puts "Main.call: #{Main.call.inspect}"
  end
end
