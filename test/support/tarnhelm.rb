# frozen_string_literal: true
require "active_support/concern"

module TarnhelmMinitestFeatureDisabler
  extend ActiveSupport::Concern

  def before_setup
    Tarnhelm.features_list.each do |feature|
      Flipper.disable(feature[:name])
    end

    super
  end

  def enable_feature(key, **kwargs)
    Tarnhelm.activate_feature(key, **kwargs)
  end

  def disable_feature(key, **kwargs)
    Tarnhelm.deactivate_feature(key, **kwargs)
  end
end

class MiniTest::Test
  include TarnhelmMinitestFeatureDisabler
end
