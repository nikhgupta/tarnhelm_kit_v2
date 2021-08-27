# frozen_string_literal: true
module UserComponents
  module Menu
    class Component < ApplicationComponent
      def initialize(user:, account:)
        @user = user
        @account = account

        super
      end

      def render?
        @user.present?
      end

      def render_gravatar
        render(SharedComponents::Gravatar::Component.new(email: @user.email, s: 32, d: :identicon))
      end
    end
  end
end
