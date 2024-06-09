# frozen_string_literal: true

module FgaClient
  def stores
    uri = uri('/stores')
    Rails.logger.debug(uri)
    HTTParty.get(uri).deep_symbolize_keys
  end

  def delete_store(store_id)
    uri = uri(store_path(store_id))
    Rails.logger.debug(uri)
    HTTParty.delete(uri)
  end

  private

  def store_path(store_id)
    "/stores/#{store_id}"
  end

  def uri(path)
    "#{fga_base_uri}#{path}"
  end

  def fga_base_uri
    config[:api_url]
  end

  def config
    Rails.configuration.openfga
  end
end
