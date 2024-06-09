# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :members, class_name: 'User', dependent: :nullify
end
