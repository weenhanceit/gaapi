# frozen_string_literal: true

require "test_helper"

class RunnerTest < Test
  def setup
    ARGV.clear
  end

  def test_no_view
    assert_output "", /gaapi: You must provide a view ID./ do
      status = Main.call
      refute status.zero?
    end
  end

  def test_empty_query
    ARGV.concat(%w[-a asldkjfalkdfj --dry-run 888888])
    assert_output "", /unexpected token at 'bogus'/ do
      begin
        $stdin = StringIO.new("bogus")
        status = Main.call
        refute status.zero?
      ensure
        $stdin = STDIN
      end
    end
  end

  def test_simple_command_line
    ARGV.concat(%w[-q basic.json -a asldkjfalkdfj --dry-run 888888])
    status = Main.call
    assert status.zero?
  end
end
