# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name

      t.timestamps
    end

    add_reference :users, :department, foreign_key: true
  end
end
