# frozen_string_literal: true

module FgaClient # rubocop:disable Metrics/ModuleLength
  def stores
    uri = uri('/stores')
    Rails.logger.debug(uri)
    HTTParty.get(uri).deep_symbolize_keys
  end

  def delete_store
    uri = uri(store_path(config[:store_id]))
    Rails.logger.debug(uri)
    HTTParty.delete(uri)
  end

  def write_tuple(user:, relation:, object:)
    data = {
      writes: {
        tuple_keys: [{
          user:,
          relation: relation.to_s,
          object:
        }]
      }
    }

    Rails.logger.debug data

    # response = HTTParty.post(uri(tuple_path), body: data.to_json, headers:)

    response = post(uri(tuple_path), data)

    raise response['message'] unless response.code == 200
  end

  def delete_tuple(user:, relation:, object:)
    data = {
      deletes: {
        tuple_keys: [{
          user:,
          relation: relation.to_s,
          object:
        }]
      }
    }

    Rails.logger.debug data

    response = HTTParty.post(uri(tuple_path), body: data.to_json, headers:)

    raise response['message'] unless response.code == 200
  end

  def list_objects(user:, relation:, type:)
    data = {
      type: type.to_s,
      relation: relation.to_s,
      user:
    }

    Rails.logger.debug data
    HTTParty.post(uri(list_objects_path), body: data.to_json, headers:)
  end

  def list_users(relation:, object:, user_filter_type:)
    type, id = object.split(':')

    data = {
      object: {
        type: type.to_s,
        id:
      },
      relation: relation.to_s,
      user_filters: [
        {
          type: user_filter_type.to_s
        }
      ]
    }

    Rails.logger.debug data
    HTTParty.post(uri(list_users_path), body: data.to_json, headers:)
  end

  def access_token
    uri = "https://#{config[:issuer]}/oauth/token"

    data = {
      grant_type: 'client_credentials',
      client_id: config[:client_id],
      client_secret: config[:client_secret],
      audience: config[:audience]
    }

    HTTParty.post(uri, body: data.to_json, headers:)
  end

  private

  def post(uri, data)
    h = headers

    if config[:issuer]
      @access_token ||= access_token['access_token']
      h = h.merge('Authorization', "Bearer #{@access_token}")
    end

    HTTParty.post(uri, body: data.to_json, headers: h)
  end

  def headers
    { 'Content-Type': 'application/json' }
  end

  def list_users_path
    "#{store_path}/list-users"
  end

  def list_objects_path
    "#{store_path}/list-objects"
  end

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
    Rails.configuration.fga
  end
end
