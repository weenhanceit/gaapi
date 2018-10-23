# frozen_string_literal: true

require "test_helper"

class AuthorizationTest < Test
  def teardown
    FileUtils.rm("credential.json") if File.exist?("credential.json")
  end

  def test_get_token_from_default_file
    skip "Can't do this because we can't chroot."
  end

  def test_get_token_from_specified_file
    stub_token_request
    File.open("credential.json", "w") do |f|
      f << CREDENTIAL
    end
    File.chmod(0o600, "credential.json")
    # access_token = GAAPI::AccessToken.new("Jade Analytics-fcb64a448d4b.json")
    access_token = GAAPI::AccessToken.new("credential.json")
    assert_equal "ya29.c.ElkQBv8eWyptfkADfqkPp9CifKK9PJhwa6fNo1_3vJ1FXZJ_6_3eOqcd-q7V8EmGkR-oPsyHE07WyeSKETVCdl-3bTf3Z4P9dANiUL99hEfKL9qr-DEJbtgoZw", access_token.token
  end

  def test_do_not_use_readable_file
    File.open("credential.json", "w") do |f|
      f << CREDENTIAL
    end
    assert_raises StandardError do
      GAAPI::AccessToken.new("credential.json")
    end
  end

  def test_file_does_not_exist
    assert_raises StandardError do
      GAAPI::AccessToken.new("credential.json")
    end
  end
end
