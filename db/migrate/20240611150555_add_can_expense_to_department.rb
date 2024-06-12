# frozen_string_literal: true

class AddCanExpenseToDepartment < ActiveRecord::Migration[7.1]
  def change
    add_column :departments, :expense_approver, :boolean, default: false
  end
end
