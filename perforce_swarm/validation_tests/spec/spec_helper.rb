require 'yaml'
require 'P4'
require_relative '../lib/log'
require_relative '../lib/config'
require_relative '../lib/git_helper'
require_relative '../lib/git_fusion_helper'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/p4_helper'
require_relative '../lib/browser'
require_relative '../lib/user'
require_relative '../lib/project'

RSpec.configure do |config|
  config.before(:suite) do
    # Creating the tmp-clients umbrella  directory under the validation_tests/spec directory
    # This ensures that there isn't a huge proliferation of  client directories on an unknown
    # location on the host machine, while allowing for multiple test runs to remain isolated
    cleanup_dirs(tmp_client_dir)
    cleanup_dirs(tmp_screenshot_dir)

    # ensure that if we're running tests via phantomjs, we have version 2
    current_driver = @driver || Browser.driver
    if current_driver && current_driver.browser == :phantomjs
      version = current_driver.capabilities[:version]
      next unless version

      if Gem::Version.new(version) < Gem::Version.new('2.0.0')
        LOG.info("Validation tests require PhantomJS version 2, and '#{version}' " \
                 'is what is being reported. Please either upgrade PhantomJS, or ' \
                 'switch to a different browser such as firefox.')
        exit(0)
      end
    end
  end

  config.before(:each, browser: true) do
    @driver = Browser.driver
  end

  config.after(:each, browser: true) do
    Browser.reset!
  end
end

def tmp_client_dir
  File.join(__dir__, '..', 'tmp-clients')
end

def tmp_screenshot_dir
  File.join(__dir__, '..', 'tmp-screenshots')
end

def unique_string
  Time.new.strftime('%H%M%S%L')
end

def create_file(directory, name = unique_string)
  FileUtils.mkdir_p(directory)
  path = directory+'/'+name
  new_file = File.open(path, 'w+')
  new_file.write 'content'
  new_file.close
  path
end

def cleanup_dirs(dir)
  FileUtils.rm_rf(dir)
  Dir.mkdir(dir) unless File.exist?(dir)
end

def run_block_with_retry(retries, seconds_between = 1, &block)
  result = false
  iteration = 0
  while !result && iteration < retries
    result = yield block if block_given?
    iteration += 1
    sleep seconds_between
  end
  result
end

def can_configure_mirroring?(user, project)
  logged_in_page = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password)
  project_page = logged_in_page.goto_project_page(project.namespace, project.name)
  can_config = project_page.can_configure_mirroring?
  if can_config
    config_mirroring_page = project_page.configure_mirroring
    config_mirroring_page.logout
  else
    project_page = project_page.goto_configure_mirroring_page_expecting_unauthorized(project.namespace, project.name)
    project_page.logout
  end
  can_config
end
