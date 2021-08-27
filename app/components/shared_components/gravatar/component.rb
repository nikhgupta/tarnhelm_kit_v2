# frozen_string_literal: true
module SharedComponents
  module Gravatar
    class Component < ApplicationComponent
      def initialize(email:, **options)
        @email = email
        @options = options

        super
      end

      def gravatar_url
        hash = Digest::MD5.hexdigest(@email.strip.downcase)
        "https://www.gravatar.com/avatar/#{hash}?#{@options.to_query}"
      end
    end
  end
end
