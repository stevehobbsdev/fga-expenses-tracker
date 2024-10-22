# frozen_string_literal: true

module FgaClient # rubocop:disable Metrics/ModuleLength
  def stores
    uri = uri('/stores')
    Rails.logger.debug(uri)
    HTTParty.get(uri).deep_symbolize_keys
  end

  def delete_store
    uri = uri(store_path)
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

    response = post(uri(tuple_path), data)

    raise response['message'] unless response.code == 200
  end

  def list_objects(user:, relation:, type:)
    data = {
      type: type.to_s,
      relation: relation.to_s,
      user:
    }

    Rails.logger.debug data
    post(uri(list_objects_path), data)
  end

  def list_users(relation:, object:, user_filter_type:)
    type, id = object.split(':')

    user_filters = user_filter_type.is_a?(Array) ? user_filter_type : [{ type: user_filter_type }]

    data = {
      object: {
        type: type.to_s,
        id:
      },
      relation: relation.to_s,
      user_filters:
    }

    Rails.logger.debug data
    post(uri(list_users_path), data)
  end

  def access_token
    uri = "https://#{config[:issuer]}/oauth/token"

    data = {
      grant_type: 'client_credentials',
      client_id: config[:client_id],
      client_secret: config[:client_secret],
      audience: config[:audience]
    }

    result = HTTParty.post(uri, body: data.to_json, headers:)
    Rails.logger.debug(result)
    result
  end

  private

  def post(uri, data)
    make_request(:post, uri, data)
  end

  def make_request(method, uri, data)
    h = headers

    unless config[:openFga]
      @access_token ||= access_token['access_token']
      h = h.merge({Authorization: "Bearer #{@access_token}"})
    end

    HTTParty.send(method, uri, body: data.to_json, headers: h)
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
