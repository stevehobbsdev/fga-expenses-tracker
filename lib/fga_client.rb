# frozen_string_literal: true

module FgaClient
  def stores
    uri = uri('/stores')
    Rails.logger.debug(uri)
    HTTParty.get(uri)
  end

  private

  def store_path(store_id)
    "/stores/#{store_id}"
  end

  def uri(path)
    "#{base_uri}#{path}"
  end

  def base_uri
    config[:api_url]
  end

  def config
    Rails.configuration.openfga
  end
end
