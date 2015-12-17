require 'spec_helper'

require_relative '../lib/page'

describe 'BasicValidationTests', browser: true do
  describe 'login page' do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      expect(@driver.title).to eq('Sign in | GitSwarm')
    end
  end

  describe 'dashboard page' do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
      expect(@driver.title).to eq('Projects | Dashboard | GitSwarm')
      dashboard.logout

      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
      expect(@driver.title).to eq('Projects | Dashboard | GitSwarm')
      dashboard.logout
    end
  end

  describe 'GitSwarm root password synced to Perforce', localGFOnly: true do
    let(:new_password) { 'new-password-123' }

    it 'should have expected p4 root password to match existing Gitswarm root password' do
      if CONFIG.get('gitswarm_username') != 'root'
        skip "Skipping test because GitSwarm admin CONFIG.get('gitswarm_username') != 'root'"
      end
      # Note that the p4 user is 'root'
      # Verify that p4 'root' user's password matches GitSwarm root user's password
      verify_p4_password(CONFIG.get('p4_port'), 'root', CONFIG.get('gitswarm_password'))
    end

    it 'should have expected p4 root password to match updated Gitswarm root password' do
      if CONFIG.get('gitswarm_username') != 'root'
        skip "Skipping test because GitSwarm admin CONFIG.get('gitswarm_username') != 'root'"
      end
      # Reset password from CONFIG.get('gitswarm_password') to 'new_password'
      reset_password(CONFIG.get('gitswarm_url'), 'root', CONFIG.get('gitswarm_password'), new_password)

      # Verify that p4 root user password is 'new_password'
      verify_p4_password(CONFIG.get('p4_port'), 'root', new_password)

      # Finally, reset the GitSwarm root user password back to its original password CONFIG.get('gitswarm_password')
      reset_password(CONFIG.get('gitswarm_url'), 'root', new_password, CONFIG.get('gitswarm_password'))

      # Verify that p4 root user password is original password
      verify_p4_password(CONFIG.get('p4_port'), 'root', CONFIG.get('gitswarm_password'))
    end
  end

  def reset_password(url, user, existing_password, new_password)
    login = LoginPage.new(@driver, url)
    password_reset_page = login.click_login_with_password_reset(user, existing_password)
    password_reset_page.set_password(existing_password, new_password)
  end

  def verify_p4_password(p4_port, user, password)
    @p4 = P4Helper.new(p4_port, user, password)
    expect(@p4.connect).to include('User root logged in.')
  end
end
