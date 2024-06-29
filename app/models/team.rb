# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :members, class_name: 'User', dependent: :nullify
end
