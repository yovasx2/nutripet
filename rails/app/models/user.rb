class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pets, dependent: :destroy

  # Password confirmation is handled by Devise's validatable module.
  # Email validation is handled by Devise :validatable

  before_validation :assign_temporary_password, on: :create

  def full_name
    "#{first_name} #{last_name_father} #{last_name_mother}".strip
  end

  private

  def assign_temporary_password
    if password.blank?
      temp_pass = SecureRandom.hex(12)
      self.password = temp_pass
      self.password_confirmation = temp_pass
    end
  end
end
