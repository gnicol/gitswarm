module SharedHelper
  include Spinach::DSL

  step 'I save a screenshot' do
    # must have the @javascript tag on the scenario
    datetime = Time.new.to_i.to_s
    screenshot_path = '/tmp/gitswarm-screenshot-' + datetime + '.jpg'
    if ::Capybara.current_driver == :poltergeist
      save_screenshot(screenshot_path, full: true)
    end
  end
end
