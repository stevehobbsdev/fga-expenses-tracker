class AddRelationshipToUsersExpenses < ActiveRecord::Migration[7.1]
  def change
    add_reference :expenses, :user, foreign_key: true, null: false # rubocop:disable Rails/NotNullColumn
  end
end
