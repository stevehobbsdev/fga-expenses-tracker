# frozen_string_literal: true

module Authorization
  include FgaClient

  def associate_user_to_expense(user_id:, expense_id:)
    write_tuple(user: "user:#{user_id}",
                relation: 'owner',
                object: "expense:#{expense_id}")
  end

  def disassociate_user_from_expense(user_id:, expense_id:)
    delete_tuple(user: "user:#{user_id}",
                 relation: 'owner',
                 object: "expense:#{expense_id}")

    # TODO: also remove any relationships to the finance team for this expense
  end

  def set_user_manager(user_id:, manager_id:)
    response = list_users(relation: 'manager', object: "user:#{user_id}", user_filter_type: 'user')
    Rails.logger.debug response.parsed_response
    manager_ids = response.parsed_response['users'].map { |u| u['object']['id'] }

    # Optization: if the user already has the manager set, skip the operation
    # if response.parsed_response['users'].size == 1 &&
    #    response.parsed_response['users'].first == "user:#{manager_id}"
    #   Rails.logger.info 'Skipping set manager for user - already set'
    #   return
    # end

    # A user should only have one manager - clear out any existing ones, then set the new one
    manager_ids.each do |id|
      delete_tuple(user: "user:#{id}", relation: 'manager', object: "user:#{user_id}")
    end

    # Write the actual manager
    write_tuple(user: "user:#{manager_id}", relation: 'manager', object: "user:#{user_id}") unless manager_id.empty?
  end
end
