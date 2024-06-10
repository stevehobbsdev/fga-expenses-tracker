# frozen_string_literal: true

module FgaClient
  def stores
    uri = uri('/stores')
    Rails.logger.debug(uri)
    HTTParty.get(uri).deep_symbolize_keys
  end

  def delete_store()
    uri = uri(store_path(config[:store_id]))
    Rails.logger.debug(uri)
    HTTParty.delete(uri)
  end

  def write_tuple(user:, relation:, object:)
    data = {
      writes: {
        tuple_keys: [{
          user:,
          relation:,
          object:
        }]
      }
    }

    Rails.logger.debug data

    response = HTTParty.post(uri(tuple_path), body: data.to_json,
                                              headers: { 'Content-Type': 'application/json' })

    raise response['message'] unless response.code == 200
  end

  private

  def tuple_path
    "#{store_path}/write"
  end

  def store_path
    "/stores/#{config[:store_id]}"
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
