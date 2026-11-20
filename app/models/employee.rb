
class Employee < ApplicationRecord
  has_many :timecards, dependent: :destroy

  validates :employee_code, presence: true, uniqueness: true
  validates :name, presence: true

  has_secure_password :pin, validations: false

  validates :pin, length: { minimum: 4 }, if: -> { pin.present? }
  validates :pin_digest, presence: true
end
