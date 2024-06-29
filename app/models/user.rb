# frozen_string_literal: true

class User < ApplicationRecord
  has_many :expenses, dependent: :destroy
  belongs_to :manager, class_name: 'User', optional: true
  belongs_to :team, optional: true
end
