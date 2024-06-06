# frozen_string_literal: true

class AddIndexOnSubToUser < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :sub, unique: true
  end
end
