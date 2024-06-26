# frozen_string_literal: true

class AddIdTokenColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :id_token, :string
  end
end
