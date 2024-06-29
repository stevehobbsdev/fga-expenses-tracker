# frozen_string_literal: true

class RenameDepartmentsToTeams < ActiveRecord::Migration[7.1]
  def change
    rename_table :departments, :teams
    rename_column :users, :department_id, :team_id
  end
end
