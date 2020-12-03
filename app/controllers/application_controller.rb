class ApplicationController < ActionController::API

  private

  def api_req(uri)
    uri_base = "https://api.zcha.in/v2/mainnet/"
    response = HTTParty.get("#{uri_base}#{uri}")
    begin
      parsed = JSON.parse(response.body)
      rescue JSON::ParserError => e
        false
      end
    end
end
