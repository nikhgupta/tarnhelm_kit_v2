module TestHooks
  def after_teardown
    super

    Faker::UniqueGenerator.clear
  end
end

class MiniTest::Test
  include TestHooks
end