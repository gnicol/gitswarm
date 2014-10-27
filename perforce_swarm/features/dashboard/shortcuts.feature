@dashboard
Feature: Dashboard Shortcuts
  Background:
    Given I sign in as a user

  # The following test cases were identified when testing the dashboard activity page
  Scenario: Navigate to activity tab
    Given I visit dashboard issues page
    When I press "g" "a"
    Then the active main tab should be Activity

  # Scenario automated in features/dashboard/shortcuts.feature
  Scenario: Navigate to projects tab
    Given I visit dashboard page  
    When I press "g" and "p"
    Then the active main tab should be Projects

  # Scenario automated in features/dashboard/shortcuts.feature
  Scenario: Navigate to issue tab
    Given I visit dashboard page
    When I press "g" and "i"
    Then the active main tab should be Issues

  # Scenario automated in features/dashboard/shortcuts.feature
  Scenario: Navigate to merge requests tab
    Given I visit dashboard page
    When I press "g" and "m"
    Then the active main tab should be Merge Requests
  
