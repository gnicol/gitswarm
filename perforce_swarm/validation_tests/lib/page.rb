require 'selenium-webdriver'
require_relative '../spec/spec_helper'

class Page
  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def goto(url)
    @driver.navigate.to url
  end

  def current_url
    @driver.current_url
  end

  #
  # Verify method checks that all expected elements exist on the page.
  # Calls child class method to get all expected elements, Blows up if
  # not valid.  This should be called at the ene of every child class'
  # constructor.
  #
  def verify
    ok = true
    if page_has_text('The page you\'re looking for could not be found.') && page_has_text('404')
      # fail fast if there is a 404 error
      msg = "404 error found on #{current_url}"
      LOG.log(msg)
      screendump
      raise msg
    end
    elements = elements_for_validation
    LOG.debug('Verifying elements : ' + elements.inspect)
    elements.each do |(by, value, timeout)|
      timeout = 10 unless timeout
      unless page_has_element(by, value, timeout)
        ok = false
        LOG.log("Element missing on page:  #{by} #{value}")
      end
    end
    unless ok
      screendump
      raise 'Could not find expected element(s) on page: ' + @driver.current_url
    end
  end

  def page_has_element(by, value, timeout = 10)
    wait_for(by, value, timeout)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  rescue Selenium::WebDriver::Error::TimeOutError
    false
  end

  def page_has_text(text)
    @driver.find_element(:tag_name, 'body').text.include?(text)
  end

  # Method to be overridden by child classes to provide elements that should be
  # verified as on the page.  Child methods get the parent list and call super
  # to get the elements from all parent classes
  #
  def elements_for_validation
    []
  end

  def wait_for(by, value, timeout = 60)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout) # seconds
    wait.until { @driver.find_element(by, value) }
  end

  def wait_for_text(type, locator, text, timeout = 60)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout) # seconds
    wait.until { @driver.find_element(type, locator).text.include?(text) }
  end

  def wait_for_no_text(type, locator, text, timeout = 60)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout) # seconds
    wait.until { !@driver.find_element(type, locator) || !@driver.find_element(type, locator).text.include?(text) }
  end

  def screendump
    uid = unique_string
    begin
      source_dumpfile = File.join(tmp_screenshot_dir, "#{uid}.html")
      File.write(source_dumpfile, @driver.page_source)
      LOG.log("Writing page source to #{source_dumpfile}")
    rescue Selenium::WebDriver::Error::UnhandledAlertError => error
      LOG.log("Failed writing page source due to #{error.message}")
    end
    image_dumpfile = File.join(tmp_screenshot_dir, "#{uid}.png")
    if @driver.respond_to?(:save_screenshot)
      LOG.log("Writing screenshot to #{image_dumpfile}")
      @driver.save_screenshot(image_dumpfile)
    end
  end

  def reload
    @driver.navigate.refresh
    verify
  end
end
Dir[File.join(__dir__, 'pages/*.rb')].each { |file| require file }
