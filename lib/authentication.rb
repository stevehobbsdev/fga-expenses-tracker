# frozen_string_literal: true

require 'httparty'
require 'jwt'

module Authentication
  def do_login
    state = SecureRandom.hex(32)
    nonce = SecureRandom.hex(32)

    params = {
      client_id: ENV.fetch('AUTH0_CLIENT_ID', nil),
      response_type: 'code',
      redirect_uri: auth_callback_url,
      scope: 'email profile openid',
      state:,
      nonce:
    }

    url = "#{base_uri}/authorize?#{params.to_query}"

    session[:auth_transaction] = JSON.generate({
                                                 state:,
                                                 nonce:
                                               })

    redirect_to url, allow_other_host: true
  end

  def handle_auth_callback(params)
    transaction = JSON.parse(session[:auth_transaction], symbolize_names: true)
    raise 'State mismatch' if transaction[:state] != params[:state]

    client_id = ENV.fetch('AUTH0_CLIENT_ID', nil)
    client_secret = ENV.fetch('AUTH0_CLIENT_SECRET', nil)
    domain = ENV.fetch('AUTH0_DOMAIN', nil)

    # Token
    token_params = {
      client_id:,
      client_secret:,
      code: params[:code],
      grant_type: 'authorization_code',
      redirect_uri: auth_callback_url
    }

    response = HTTParty.post("#{base_uri}/oauth/token", { body: token_params }).parsed_response

    raise response['error'] if response['error']

    id_token = response['id_token']

    client = Auth0Client.new(
      client_id:,
      client_secret:,
      domain:,
      token: response['access_token']
    )

    # This will throw an error if not valid
    client.validate_id_token(id_token, nonce: transaction[:nonce])
    decoded_token = JWT.decode(id_token, nil, false)

    # Create a user
    

    # TODO: Add the user to FGA

    session[:user_session] = decoded_token[0]['sub']
  end

  def logged_in?
    !!user_session
  end

  def user_session
    session[:user_session]
  end

  def base_uri
    "https://#{ENV.fetch('AUTH0_DOMAIN')}"
  end
end
