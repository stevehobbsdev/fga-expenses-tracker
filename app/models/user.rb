# frozen_string_literal: true

class User < ApplicationRecord
  has_many :expenses, dependent: :destroy
  has_one :manager, class_name: 'User', foreign_key: :manager_id
end
