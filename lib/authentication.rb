# frozen_string_literal: true

require 'httparty'
require 'jwt'

module Authentication
  #
  # Performs the login process by generating the necessary parameters,
  # constructing the authorization URL, and redirecting the user to it.
  #
  # @return [void]
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

  # Handles the authorization callback by validating the state parameter,
  # exchanging the authorization code for an access token, validating the ID
  # token, and creating or updating the user's session.
  #
  # @param params [Hash] The parameters received in the authorization callback.
  # @return [User] The user object associated with the session.
  # @raise [RuntimeError] If the state parameter does not match the stored state.
  # @raise [RuntimeError] If an error occurs during the token exchange.
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
    JWT.decode(id_token, nil, false)[0].symbolize_keys => {sub:, email:, name:}

    # Create a user if not available
    user = User.find_by(sub:)

    if user
      user.update id_token:
    else
      User.create(sub:, email:, name:, id_token:)
    end

    # TODO: Add the user to FGA

    # TODO: Make this longer lasting than just session
    session[:user_session] = sub
    user
  end

  # Determines if a user is currently logged in.
  #
  # Returns:
  # - true if the user is logged in
  # - false if the user is not logged in
  # Determines if a user is currently logged in.
  #
  # Returns:
  # - true if the user is logged in, false otherwise.
  def logged_in?
    !!user_session
  end

  #
  # Returns the user session stored in the session hash.
  #
  # @return [Object] the user session object
  def user_session
    session[:user_session]
  end

  # Public: Removes the user session and signs out of the IdP.
  #
  # Examples
  #
  #   remove_session
  #
  # Raises
  #
  # - RuntimeError: If no user is found.
  #
  # Returns nothing.
  def remove_session
    sub = user_session
    user = User.find_by(sub:)

    raise 'No user' unless user

    session.delete :user_session

    # Sign out of the IdP
    logout_params = {
      post_logout_redirect_uri: root_url,
      id_token_hint: user.id_token
    }

    redirect_to "#{base_uri}/oidc/logout?#{logout_params.to_query}", allow_other_host: true
  end

  # Returns the base URI for authentication.
  #
  # The base URI is constructed using the `AUTH0_DOMAIN` environment variable.
  #
  # @return [String] The base URI for authentication.
  def base_uri
    "https://#{ENV.fetch('AUTH0_DOMAIN')}"
  end
end
