# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :user
  enum :status, %i[submitted manager_approved approved rejected]
end
