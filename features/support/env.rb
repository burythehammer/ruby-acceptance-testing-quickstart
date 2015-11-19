require 'capybara/cucumber'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'selenium/webdriver'
require 'dotenv'

Dotenv.load # loads environment variables from .env file

DEFAULT_CAPYBARA_DRIVER = :poltergeist
BROWSERSTACK_USERNAME = ENV['BROWSERSTACK_USERNAME']
BROWSERSTACK_AUTH_KEY = ENV['BROWSERSTACK_AUTH_KEY']
BROWSERSTACK_URL = "http://#{BROWSERSTACK_USERNAME}:#{BROWSERSTACK_AUTH_KEY}@hub.browserstack.com/wd/hub"

# CHROME
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# POLTERGEIST (phantom.js driver for Capybara)
Capybara.register_driver :poltergeist do |app|
  options = {
    js_errors: false,
    timeout: 120,
    debug: false,
    phantomjs_options: ['--load-images=no', '--disk-cache=false'],
    inspector: true
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

def setup_browserstack

  Capybara.register_driver :selenium do |app|
    caps = {
      os: ENV['BROWSERSTACK_OS'],
      os_version: ENV['BROWSERSTACK_OS_VERSION'],
      browser:  ENV['BROWSERSTACK_BROWSER'],
      resolution: ENV['BROWSERSTACK_RESOLUTION'],
      browser_version: ENV['BROWSERSTACK_BROWSER_VERSION'],
      :"browserstack.debug" => "false",
      :"browserstack.local" => "false",
    }

    Capybara::Selenium::Driver.new(app, {
      :browser => :remote,
      :url => BROWSERSTACK_URL,
      :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.new(caps)
      })
    end
end

Capybara.default_driver = case ENV['DRIVER']
when 'firefox' then :selenium
when 'chrome' then  :chrome
when 'phantom.js' then :poltergeist
when 'browserstack' then :selenium
else DEFAULT_CAPYBARA_DRIVER
end

setup_browserstack if ENV['DRIVER'] == 'browserstack'
