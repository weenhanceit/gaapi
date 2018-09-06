# frozen_string_literal: true

module GAAPI
  class AccessToken
    def initialize(credential_file = nil)
      @credential_file = credential_file || File.expand_path("~/.gaapi/ga-api-key")
      stat = File::Stat.new(@credential_file)
      raise "#{@credential_file} must be readable and writable only by you." if stat.world_readable? || stat.world_writable?
    end

    def token
      (@token ||= fetch_access_token)["access_token"]
    end
    alias to_s token

    private

    def fetch_access_token
      File.open(@credential_file) do |fd|
        authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: fd,
          scope: "https://www.googleapis.com/auth/analytics.readonly"
        )
        authorization.fetch_access_token!
      end
    end
  end
end
