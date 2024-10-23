# frozen_string_literal: true

def client
  Rails.configuration.auth0 => { domain:, client_id:, client_secret: }

  Auth0Client.new(
    client_id:,
    client_secret:,
    domain:
  )
end

def users
  password = 'Test1ing'

  [
      {
        email: 'steve.hobbs+engineer@hey.com',
        username: 'engineer',
        name: 'Ernie Engineer',
        password:
      },
      {
        email: 'steve.hobbs+manager@hey.com',
        username: 'manager',
        name: 'Mandy Manager',
        password:
      },
      {
        email: 'steve.hobbs+fineng@hey.com',
        username: 'finance_member',
        name: 'Fiona Finance',
        password:
      },
      {
        email: 'steve.hobbs+finmgr@hey.com',
        username: 'finance_manager',
        name: 'Frank Finance Manager',
        password:
      }
    ]
end

namespace :auth0 do
  task create_users: :environment do
    connection = 'Username-Password-Authentication'

    users.each do |user|
      result = client.create_user(connection, user)
      pp result
    rescue StandardError => e
      raise e unless e.http_code == 409
    end
  end

  task list_users: :environment do
    users.each do |user|
      case client.users_by_email(user[:email], { fields: 'email,name,user_id' })
      in [user] then pp user.symbolize_keys
      end
    end
  end
end
