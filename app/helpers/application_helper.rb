# frozen_string_literal: true

module ApplicationHelper
  def default_table_row_classes
    'px-3 py-4 text-left text-sm font-normal text-gray-600 border-b border-gray-100'
  end

  def default_table_header_classes
    'p-3 text-left text-sm font-medium text-gray-500 border-b border-gray-200'
  end

  def expense_status(status)
    case status
    when 'submitted'
      'Submitted'
    when 'manager_approved'
      'Approved by manager, pending finance sign-off'
    when 'approved'
      'Approved'
    when 'rejected'
      'Rejected'
    end
  end

  def show_approve_buttons?(expense)
    (@authenticated_user.department.expense_approver? && expense.status.to_sym == :manager_approved) ||
      (@authenticated_user.role.to_sym == :manager && expense.status.to_sym == :submitted)
  end
end
