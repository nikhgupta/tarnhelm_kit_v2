# frozen_string_literal: true
class Account < ApplicationRecord
  include Encryptable

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates_presence_of :name
  scope :personal, -> { where(personal: true) }
  scope :impersonal, -> { where(personal: false) }

  def display_name
    personal? ? "Personal Account" : name
  end
end
