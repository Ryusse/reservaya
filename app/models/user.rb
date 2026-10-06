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

  validates :name, presence: true, length: { maximum: 50 },
            format: { without: /[<>]/, message: "contiene caracteres inválidos" }
  
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            length: { maximum: 100 },
            format: { with: URI::MailTo::EMAIL_REGEXP }
            
  validates :password, length: { minimum: 6, maximum: 64 }, 
            format: { with: /\A(?=.*[A-Z])(?=.*[0-9]).*\z/m, message: "debe contener al menos una letra mayúscula y un número" },
            if: -> { new_record? || password.present? }
end
