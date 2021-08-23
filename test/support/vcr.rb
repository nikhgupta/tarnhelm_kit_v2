# frozen_string_literal: true

require "vcr"

driver_urls = Webdrivers::Common.subclasses.map do |driver|
  Addressable::URI.parse(driver.base_url).host
end

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into(:webmock)

  config.ignore_localhost = true
  config.ignore_hosts(*driver_urls)
end

WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)
WebMock.allow_net_connect!(net_http_connect_on_start: true)
