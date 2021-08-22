# frozen_string_literal: true

module Tarnhelm
  module Feature
    def feature_record_for(feat_or_name)
      feat_or_name = feat_or_name.key if feat_or_name.respond_to?(:key)
      Flipper::Adapters::ActiveRecord::Feature.find_by(key: feat_or_name)
    end

    def activate_feature(name, description, percentage: nil)
      deactivate_feature(name)
      percentage ? Flipper.enable_percentage_of_actors(name, percentage) : Flipper.enable(name)
      feature_record_for(name).update(description: description)
    end

    def deactivate_feature(name)
      Flipper.disable(name)
    end

    def active?(feature, _user = nil)
      feature = Flipper.feature(feature) unless feature.respond_to?(:key)

      feature.on? ||
        feature.percentage_of_time_value == 100 ||
        feature.percentage_of_actors_value == 100
    rescue StandardError
      false
    end

    def inactive?(feature)
      feature = Flipper.feature(feature) unless feature.respond_to?(:key)

      feature.off? &&
        feature.percentage_of_time_value.zero? &&
        feature.percentage_of_actors_value.zero?
    end

    def features_list
      Flipper.features.map do |feature|
        get_feature_info(feature)
      end
    end

    def get_feature_info(feature)
      feature = Flipper.feature(feature) unless feature.respond_to?(:key)

      key = feature.key
      record = feature_record_for(feature)
      status = active?(key) ? :active : :partially_active
      status = inactive?(key) ? :inactive : status

      {
        key: key,
        status: status,
        record: record,
        feature: feature,
        name: key.to_s.titleize,
        description: record.try(:description),
        status_humanized: feature_stats_humanized(feature),
      }
    end

    def feature_stats_humanized(feature)
      feature = Flipper.feature(feature) unless feature.respond_to?(:key)
      return "enabled globally" if feature.on?

      value = feature.percentage_of_time_value
      return "enabled #{format("%0.2f", value)}% time" if value.positive?

      value = feature.percentage_of_actors_value
      return "enabled for #{format("%0.2f", value)}% actors" if value.positive?

      "disabled globally"
    end
  end
end
