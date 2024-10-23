# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
%w[Engineering Finance].each do |team|
  Team.create(name: team)
end

finance = Team.find_by(name: 'Finance')
finance.update(expense_approver: true)

engineering = Team.find_by(name: 'Engineering')

# Users
User.create(
  name: 'Ernie Engineer',
  sub: 'custom|1',
  email: 'steve.hobbs+engineer@hey.com',
  team: engineering
)

User.create(
  name: 'Mandy Manager',
  sub: 'custom|2',
  email: 'steve.hobbs+manager@hey.com',
  team: engineering,
  role: 'manager'
)
