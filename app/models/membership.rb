# frozen_string_literal: true
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :invitee, class_name: "User", foreign_key: :invited_by_id, optional: true

  delegate :salt, to: :account
  include Encryptable

  validates_uniqueness_of :user_id, scope: :account_id, case_sensitive: false
end
