# frozen_string_literal: true

Flipper::UI.configure do |config|
  config.descriptions_source = ->(keys) do
    # descriptions loaded from YAML file or database (postgres, mysql, etc)
    # return has to be hash of {String key => String description}
    Flipper::Adapters::ActiveRecord::Feature.where(key: keys).pluck(:key, :description).to_h
  end

  # Defaults to false. Set to true to show feature descriptions on the list
  # page as well as the view page.
  config.show_feature_description_in_list = true

  config.banner_text = "#{Rails.env.to_s.titleize} Environment"
  config.banner_class = Rails.env.production? ? "danger" : "success"
end

if ENV["TARNHELM_USE_OMNIAUTH_WITHOUT_REGISTRATIONS"].blank?
  if Tarnhelm.active?(:user_omniauth) && Tarnhelm.inactive?(:user_registrations)
    Rails.logger.warn(<<~MESSAGE)
      [RECOMMENDED] - You should also activate user_registrations feature or disable omniauth!
                    - You can disable this recommendation by setting TARNHELM_USE_OMNIAUTH_WITHOUT_REGISTRATIONS environment variable.
    MESSAGE
  end
end

if ENV["TARNHELM_DISABLE_USER_LOGIN"].blank?
  if Tarnhelm.inactive?(:user_passwords) && Tarnhelm.inactive?(:user_magic_links) && Tarnhelm.inactive?(:user_omniauth)
    Rails.logger.warn(<<~MESSAGE)
      [RECOMMENDED] - You should enable one of user_passwords, user_magic_links or user_omniauth.
                    - Currently, users are unable to login.
                    - You can disable this recommendation by setting TARNHELM_DISABLE_USER_LOGIN environment variable.
    MESSAGE
  end
end
