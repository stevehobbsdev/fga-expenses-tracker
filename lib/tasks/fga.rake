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
          object: "team:#{user.department_id}"
        )
      rescue StandardError
        Rails.logger.error "Failed to write team tuple for user: #{user.id}, team #{user.department_id}"
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
    delete_store(Rails.configuration.openfga[:store_id])
  end
end
