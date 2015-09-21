require_relative '../page'
require_relative 'logged_in_page'
require_relative 'login_page'

class PasswordResetPage < LoggedInPage

  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id,'user_current_password']
    elems << [:id,'user_password']
    elems << [:id,'user_password_confirmation']
    elems << [:name, 'commit']
    return elems
  end

  # sets the password.  If no new_password is supplied, the password will be set to the old password
  # returns the login page
  def set_password(old_password, new_password=old_password)
    @driver.find_element(:id, 'user_current_password').send_keys(old_password)
    @driver.find_element(:id, 'user_password').send_keys(new_password)
    @driver.find_element(:id, 'user_password_confirmation').send_keys(new_password)
    @driver.find_element(:name, 'commit').click
    return LoginPage.new(@driver)
  end

end