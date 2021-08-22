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
