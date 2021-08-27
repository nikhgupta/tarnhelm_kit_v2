# frozen_string_literal: true
module MinitestMatchers
  def assert_routes_disabled(*routes, method: :get)
    exceptions = []
    routes.each do |route|
      [method].flatten.each do |m|
        if route.is_a?(String)
          message = "#{m.to_s.upcase}: #{route} exists"
        else
          message = "#{m.to_s.upcase}: #{route}_path (#{send("#{route}_path")}) exists"
          route = send("#{route}_url")
        end

        exceptions << assert_raises(ActionController::RoutingError, message) do
          send(m, route)
          follow_redirect! if response.redirect?
        end
      end
    end

    exceptions
  end

  def assert_routes_available(*routes, method: :get)
    routes.each do |route|
      [method].flatten.each do |m|
        send(m, route.is_a?(String) ? route : send("#{route}_url"))
        follow_redirect! if response.redirect?
      end
    end
  end
end

class MiniTest::Test
  include MinitestMatchers
end
