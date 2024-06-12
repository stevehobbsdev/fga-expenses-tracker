# frozen_string_literal: true

class AddStatusToExpense < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :status, :integer, default: 0, null: false
  end
end
