# frozen_string_literal: true

class User < ApplicationRecord
  # Devise is the standard Bowerbird auth stack (Gilded Kestrel / Heritage Rampart).
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  ROLES = %w[admin member staff].freeze

  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }, allow_nil: true

  before_validation :normalize_email
  before_validation :default_role

  scope :admins, -> { where(admin: true).or(where(role: "admin")) }

  def admin?
    admin == true || role.to_s == "admin"
  end

  def display_name
    name.presence || email.to_s.split("@").first
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def default_role
    self.role = admin? ? "admin" : "member" if role.blank?
  end
end
