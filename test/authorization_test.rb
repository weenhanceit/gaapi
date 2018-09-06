# frozen_string_literal: true

require "test_helper"

class AuthorizationTest < Test
  CREDENTIAL = <<~CREDENTIAL
    {
      "type": "service_account",
      "project_id": "tenacious-ring-000000",
      "private_key_id": "private_key_id",
      "private_key": "-----BEGIN PRIVATE KEY-----\\nprivate key\\n-----END PRIVATE KEY-----\\n",
      "client_email": "example-admin@tenacious-ring-000000.iam.gserviceaccount.com",
      "client_id": "client id",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://accounts.google.com/o/oauth2/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/example-admin%40tenacious-ring-000000.iam.gserviceaccount.com"
    }
  CREDENTIAL

  def teardown
    FileUtils.rm("credential.json") if File.exist?("credential.json")
  end

  def test_get_token_from_default_file
    skip "Can't do this because we can't chroot."
  end

  def test_get_token_from_specified_file
    body = <<~ACCESS_TOKEN
      {
        "access_token" : "ya29.c.ElkQBv8eWyptfkADfqkPp9CifKK9PJhwa6fNo1_3vJ1FXZJ_6_3eOqcd-q7V8EmGkR-oPsyHE07WyeSKETVCdl-3bTf3Z4P9dANiUL99hEfKL9qr-DEJbtgoZw",
        "expires_in" : 3600,
        "token_type" : "Bearer"
      }
    ACCESS_TOKEN
    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(body: body, status: 200, headers: { "content-type": "application/json; charset=utf-8" })
    File.open("credential.json", "w") do |f|
      f << CREDENTIAL
    end
    File.chmod(0o600, "credential.json")
    access_token = GAAPI::AccessToken.new("Jade Analytics-fcb64a448d4b.json")
    # access_token = GAAPI::AccessToken.new("credential.json")
    assert_equal "ya29.c.ElkQBv8eWyptfkADfqkPp9CifKK9PJhwa6fNo1_3vJ1FXZJ_6_3eOqcd-q7V8EmGkR-oPsyHE07WyeSKETVCdl-3bTf3Z4P9dANiUL99hEfKL9qr-DEJbtgoZw", access_token.token
  end

  def test_do_not_use_readable_file
    File.open("credential.json", "w") do |f|
      f << CREDENTIAL
    end
    # access_token = GAAPI::AccessToken.new("Jade Analytics-fcb64a448d4b.json")
    assert_raises StandardError do
      GAAPI::AccessToken.new("credential.json")
    end
  end
end
