# frozen_string_literal: true

require "test_helper"

class AuthorizationTest < Test
  CREDENTIAL = <<~CREDENTIAL
    {
      "type": "service_account",
      "project_id": "tenacious-ring-184815",
      "private_key_id": "65f01f547ac55ffb9515c4f667746a1b5f654eec",
      "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/cnx4HuEaPM4g\\npFjLcBPgFE7E1UReZyPSPn0cJFIXB/YLX/EihMQhii+STPmJo7qv65EIcMw7/nvk\\nao2KD7yC+WdhOITcs+cX8dWZY3BvkwBSY2urFjf282jVlCM6BEPMfHdNoDWeK7Qz\\nGU+Xs+QJ9RpT6DRyjFBJI+BLZ0K0ivQR+gzs03LZgN/PKYG35EY1Db7z4KmmRs3T\\nsCTiEDxaKXJ3PfsxDYdJLbegHrMCYttJkklbkWXQ8O1o0uWY2jzBzgkkZ8Ui0QUk\\nL+ijyXfAyilBcuuM0f1WaOvYuGKy1xJPKcUtrzhaV+2tmhnZKVMofSZYbBfaIsPs\\n1cSX1e1tAgMBAAECggEAAuQgahLGG0agzEOYtBXKTwxJD9YZDreBbHriGjGYOPdq\\nguVDhHehzwN06kFiuu5JWVlcdHBG1uV/pHiEqhMu9k4vsZTdBZVrH34lviFcANG+\\nlv/swwXDLMw9oIzfDVC9xcUTBI3I6xpFqEhKq4O3C8lzFaJNLHYSMYPEe6igpfS0\\n8FF3W5NEa6a2TGIa2HVE83mCpd4gv9y/hUqOT2YLv/339ajeXra7TMmxx2FXDzrL\\nLuA/fqFoYSTdqwXfyyhhfuKLPYjL/H2i0bR5nVXWZt+tWbcEXiwrJY51CF0aV+Le\\nbelmiq6JXSb5bj+h3GMG3jYCOs9nl0CCh2TeCz3zUQKBgQDsqUQ+4lh9esIZngBR\\nBA87aZFoOBLcm7sncEM+Bye49f2R4bkYtsNvOaNj4EzSXcZZr+ubvoxj4WUyZ7CY\\nDmRHhdRJks9TowKbg85aF1o7gidWwSXX8mvY2F3g2enigYN9tMJJpjS+H7SpytXr\\n0TKs+54ullA6UmvrAXI+JvRJxQKBgQDPF2KFbFOXQ2Vd85kUuX47aZC918WSK/cu\\nW6VKTCMP8IsugyWIi3A+T+W/aXJrjbSwJEl9MmxkoO0QDl3edlFD+wPHJzkeyBjh\\nJQaNvnj6NGyZmNtSDB/OiCFKd1XBJWYfaEsRP6cprxQZVGGZtUWNq4TdUV/Ds2cH\\nTAbWAO7XiQKBgQDosU2O3xLO3cK3WWlKP0mSyyvTYz74do7AKluTQ4nFDOlzZJOQ\\nPzNNy0hhzYr7VITQbm6kxehX1KihtN4nxA7JXEbsyFLeE2te6WwdnNR1qnVvkZ3a\\nBFwR7Dvx95FFyr40/WQC8k7tmVMTl4JayWigOQ7BE75yedPuT4+6mKadWQKBgBga\\nlLEK5r/YbFf/HnY3EOZBZ0NxdeGJlH+k0xxOuFYGnWyQfzHhaPMXwZoB3/t8xucp\\nkhQsZklgIbeYtHxMMTFEajAn9JIMoDi0York/JfCulE2ZXCrUJhtZ9KPCUAt5jEJ\\nppMfYYmMgz5ff+ywGKRgrlpEOm1A2GEVDEakXShhAoGAastPeZDNc9ryX1ar1Bgo\\ncWYt0E0XM33rMGL01+xDWIToatwB6494Wyps2BZ+U3QGu+mliRnkLF1Cu4vZPVpV\\n7V23WsRA7mLMJ9LYkrlQU6Qqvtf2V9j01terav+/Nm8oSRXpEF2LO/0XFtAUXlAw\\nZDsqiPINtm/qS3cX3o0oLY8=\\n-----END PRIVATE KEY-----\\n",
      "client_email": "jade-admin@tenacious-ring-184815.iam.gserviceaccount.com",
      "client_id": "102325076154081514620",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://accounts.google.com/o/oauth2/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/jade-admin%40tenacious-ring-184815.iam.gserviceaccount.com"
    }
  CREDENTIAL
  # CREDENTIAL = <<~CREDENTIAL
  #   {
  #     "type": "service_account",
  #     "project_id": "tenacious-ring-000000",
  #     "private_key_id": "private_key_id",
  #     "private_key": "-----BEGIN PRIVATE KEY-----\\nprivate key\\n-----END PRIVATE KEY-----\\n",
  #     "client_email": "example-admin@tenacious-ring-000000.iam.gserviceaccount.com",
  #     "client_id": "client id",
  #     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  #     "token_uri": "https://accounts.google.com/o/oauth2/token",
  #     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  #     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/example-admin%40tenacious-ring-000000.iam.gserviceaccount.com"
  #   }
  # CREDENTIAL

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
