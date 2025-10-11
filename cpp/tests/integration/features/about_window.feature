Feature: About Window
  As a user
  I want to view information about the Treon application
  So that I can understand the app's version, credits, and technical details

  Background:
    Given the application is running
    And the About Window is available

  Scenario: Viewing basic application information
    When I open the About Window
    Then I should see the application name "Treon"
    And I should see the version number "1.0.0"
    And I should see the copyright information
    And I should see the organization name "CycleRunCode Club"

  Scenario: Viewing technical information
    When I open the About Window
    Then I should see the Qt version information
    And I should see the build information
    And I should see the platform information
    And I should see the compiler information

  Scenario: Viewing third-party libraries
    When I open the About Window
    Then I should see a list of third-party libraries
    And the list should include Qt
    And the list should include CMake
    And the list should include other dependencies

  Scenario: Viewing credits
    When I open the About Window
    Then I should see the development team credits
    And I should see the organization name
    And I should see contributor information

  Scenario: Copying version information
    When I open the About Window
    And I click the "Copy" button next to version information
    Then the version information should be copied to clipboard
    And I should see a confirmation message

  Scenario: Copying system information
    When I open the About Window
    And I click the "Copy" button next to build information
    Then the system information should be copied to clipboard
    And I should see a confirmation message

  Scenario: Opening external links
    When I open the About Window
    And I click the "Website" button
    Then the website should open in the default browser
    And the URL should contain "cycleruncode.club"

    When I click the "Documentation" button
    Then the documentation should open in the default browser
    And the URL should contain "cycleruncode.club/docs"

    When I click the "Support" button
    Then the support page should open in the default browser
    And the URL should contain "cycleruncode.club/support"

    When I click the "View License" button
    Then the license page should open in the default browser
    And the URL should contain "cycleruncode.club/license"

  Scenario: Window visibility management
    When the About Window is not visible
    And I call the show method
    Then the About Window should become visible

    When the About Window is visible
    And I call the hide method
    Then the About Window should become hidden

    When the About Window is not visible
    And I call the toggle method
    Then the About Window should become visible

    When the About Window is visible
    And I call the toggle method
    Then the About Window should become hidden

  Scenario: Application icon display
    When I open the About Window
    Then I should see the application icon
    And the icon should be properly sized
    And the icon should be clear and visible

  Scenario: Responsive layout
    When I open the About Window
    Then the layout should be properly organized
    And all text should be readable
    And buttons should be properly aligned
    And the window should be scrollable if content overflows
