# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  name            :string
#  password_digest :string
#  role            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  
  has_many :reservations, dependent: :destroy

  enum :role, { user: 0, admin: 1 }

  validates :name, presence: true
  validates :email, presence: true,
            uniqueness: { case_sensitive: false, message: "ya está registrado" },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
end
