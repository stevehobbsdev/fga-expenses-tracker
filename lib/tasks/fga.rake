# frozen_string_literal: true

desc 'Tasks relating to FGA management'

namespace :fga do
  task seed: :environment do
    include FgaClient

    User.find_each do |user|
      begin
        write_tuple(user: "user:#{user.manager_id}", relation: :manager, object: "user:#{user.id}") if user.manager_id
      rescue StandardError
        Rails.logger.error "Failed to write manager tuple for user: #{user.id}"
      end

      # Write the department tuple
      begin
        write_tuple(
          user: "user:#{user.id}",
          relation: :member,
          object: "team:#{user.team_id}"
        )
      rescue StandardError
        Rails.logger.error "Failed to write team tuple for user: #{user.id}, team #{user.team_id}"
      end
    end

    Expense.find_each do |expense|
      write_tuple(user: "user:#{expense.user_id}", relation: 'owner', object: "expense:#{expense.id}")
    rescue StandardError
      Rails.logger.error "Failed to write owner tuple for expense: #{expense.id}"
    end
  end

  task clean: :environment do
    include FgaClient
    delete_store

    User.destroy_all
    Team.destroy_all
    Expense.destroy_all
  end

  task token: :environment do
    include FgaClient
    token = access_token

    if token['error']
      pp token['error_description']
    else
      pp token['access_token']
    end
  end

  task debug: :environment do
    sh "fga store export --store-id=#{Rails.configuration.fga.store_id}"
  end
end
