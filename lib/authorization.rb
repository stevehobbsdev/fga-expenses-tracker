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
    response = list_objects(user: "user:#{user_id}", relation: 'manager', type: 'user')
    Rails.logger.debug response.parsed_response

    response.parsed_response['objects'].each do |object_str|
      # Remove these tuples
      delete_tuple(user: "user:#{user_id}", relation: 'manager', object: object_str)
    end

    # Write the actual manager
    write_tuple(user: "user:#{user_id}", relation: 'manager', object: "user:#{manager_id}")
  end
end
