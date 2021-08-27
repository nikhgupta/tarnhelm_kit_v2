# frozen_string_literal: true

module SharedComponents
  module Flash
    class Component < ApplicationComponent
      def initialize(flash:, dismissable: true)
        @flash = flash
        @dismissable = dismissable

        super
      end
    end
  end
end
