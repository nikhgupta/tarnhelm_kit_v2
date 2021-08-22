# frozen_string_literal: true

module Logo
  class Component < ApplicationComponent
    def initialize(title:)
      @title = title
      super
    end
  end
end
