# frozen_string_literal: true

module GAAPI
  # An access token generated from a credential file provided by Google Analystics.
  # The credential file is suitable for using in applications where humans aren't
  # involved, such as scheduled jobs. To obtain a credential file, follow the instructions
  #   at https://developers.google.com/identity/protocols/OAuth2ServiceAccount.
  class AccessToken
    # Get a new access token. The actual token is lazily-generated, so no call is
    # made to Google Analytics until #token is called.
    # @param credential_file [String] File name of a credential file provided by
    #   Google Analytics.
    def initialize(credential_file = nil)
      @credential_file = credential_file || File.expand_path("~/.gaapi/ga-api-key")
      stat = File::Stat.new(@credential_file)
      raise "#{@credential_file} must be readable and writable only by you." if stat.world_readable? || stat.world_writable?
    end

    # An access token that can be used in a request to Google Analytics Reporting API v4.
    # @return [String] An access token.
    def token
      (@token ||= fetch_access_token)["access_token"]
    end

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
