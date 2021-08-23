# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = "created_at"

  def add_info_if_missing(key, val)
    send("#{key}=", val) if val.present? && send(key).blank?
  end
end
