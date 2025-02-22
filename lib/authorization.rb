# frozen_string_literal: true

module Authorization
  include FgaClient

  def associate_user_to_expense(user_id:, expense_id:)
    write_tuple(user: "user:#{user_id}",
                relation: :owner,
                object: "expense:#{expense_id}")
  end

  def associate_team_to_expense(team_id:, expense_id:)
    write_tuple(
      user: "team:#{team_id}#member",
      relation: :can_approve,
      object: "expense:#{expense_id}"
    )
  end

  def remove_user_from_team(user_id:, team_id:)
    delete_tuple(user: "user:#{user_id}",
                 relation: :member,
                 object: "team:#{team_id}")
  rescue StandardError => _e # rubocop:disable Lint/SuppressedException
  end

  def associate_user_to_team(user_id:, team_id:)
    write_tuple(
      user: "user:#{user_id}",
      relation: :member,
      object: "team:#{team_id}"
    )
  end

  def disassociate_user_from_expense(user_id:, expense_id:)
    delete_tuple(user: "user:#{user_id}",
                 relation: :owner,
                 object: "expense:#{expense_id}")
  end

  def disassociate_team_from_expense(team_id:, expense_id:)
    delete_tuple(
      user: "team:#{team_id}#member",
      relation: :can_approve,
      object: "expense:#{expense_id}"
    )
  end

  def remove_expense(expense_id:)
    # Remove the expense from the user
    user_response = list_users(object: "expense:#{expense_id}", user_filter_type: :user, relation: :owner)
    user_ids = user_response.parsed_response['users']&.map { |u| u['object']['id'] } || []

    user_ids.each do |id|
      delete_tuple(user: "user:#{id}", relation: :owner, object: "expense:#{expense_id}")
    end

    # Remove from any teams that might approve this expense
    team_filter = {
      type: 'team',
      relation: 'member'
    }

    response = list_users(object: "expense:#{expense_id}", user_filter_type: [team_filter], relation: 'can_approve')

    response.parsed_response['users']&.each { |u|
      userset = u['userset']
      delete_tuple(user: "team:#{userset['id']}#member", relation: :can_approve, object: "expense:#{expense_id}")
    } || []

    Rails.logger.debug(response.parsed_response)
  end

  def set_user_manager(user_id:, manager_id:)
    # Question: is this deterministic (will I get the same order every time?)
    # Could be critical when thinking about performance of an IN clause, which is
    # what this will result in. If the order is derministic, we could reliably
    # page the results and not have to worry about missing any.
    response = list_users(object: "user:#{user_id}", user_filter_type: :user, relation: :manager)
    Rails.logger.debug response.parsed_response
    manager_ids = response.parsed_response['users']&.map { |u| u['object']['id'] } || []

    # Optization: if the user already has the manager set, skip the operation
    # if response.parsed_response['users'].size == 1 &&
    #    response.parsed_response['users'].first == "user:#{manager_id}"
    #   Rails.logger.info 'Skipping set manager for user - already set'
    #   return
    # end

    # A user should only have one manager - clear out any existing ones, then set the new one
    manager_ids.each do |id|
      delete_tuple(user: "user:#{id}", relation: :manager, object: "user:#{user_id}")
    end

    # Write the actual manager
    write_tuple(user: "user:#{manager_id}", relation: :manager, object: "user:#{user_id}") unless manager_id.empty?
  end

  def expense_approvals_for(user_id:)
    response = list_objects(user: "user:#{user_id}", relation: :can_approve, type: :expense)
    Rails.logger.debug response.parsed_response

    response.parsed_response['objects'].map do |o|
      o.split(':').last.to_i
    end
  end
end
