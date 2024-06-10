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
end
