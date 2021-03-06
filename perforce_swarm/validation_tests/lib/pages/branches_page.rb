require_relative 'logged_in_page'

class BranchesPage < LoggedInPage
  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'btn-create'] # create branch button
    elems
  end

  def available_branches
    elems = @driver.find_element(:class, 'all-branches').find_elements(:class, 'item-title')
    branches = []
    elems.each { |br| branches << br.text }
    branches
  end

  def create_branch(new_branch, source_branch)
    url = current_url
    @driver.find_element(:class, 'btn-create').click
    wait_for(:id, 'branch_name')
    @driver.find_element(:id, 'branch_name').send_keys(new_branch)
    @driver.find_element(:id, 'ref').send_keys(source_branch)
    @driver.find_element(:class, 'btn-create').click
    goto(url)
  end

  # Fails if there are no changes in the branch to merge
  # returns a MergeRequestPage
  def create_merge_request(branch, title)
    # finds the first button which should be merge request - not a great search
    LOG.log('Creating merge request for '+branch)
    @driver.find_element(:class, 'js-branch-'+branch).find_element(:class, 'btn').click
    nmrp = NewMergeRequestPage.new(@driver)
    raise 'There are no changes to merge' unless nmrp.changes?
    nmrp.create_merge_request(title)
  end

  # returns you to this page
  def create_and_accept_merge_request(branch, title, delete_source = true)
    url = current_url
    mrp = create_merge_request(branch, title)
    mrp.remove_source_branch(delete_source)
    mrp.accept_merge_request
    goto(url)
  end
end
