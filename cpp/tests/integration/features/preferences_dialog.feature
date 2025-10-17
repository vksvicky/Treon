Feature: Preferences Dialog
  As a user of Treon
  I want to configure application settings through a native preferences dialog
  So that I can customize the application behavior and appearance

  Background:
    Given the application is running
    And the native C++ preferences dialog is available

  Scenario: Open Preferences Dialog
    Given the application is running
    When I click "Treon" > "Preferences..." from the menu
    Or I press "Cmd+,"
    Then the C++ preferences dialog should open
    And it should have a proper title bar with close button
    And it should be centered on the screen
    And it should be modal

  Scenario: Language Selection
    Given the preferences dialog is open
    When I look at the Language section
    Then I should see a dropdown with language options
    And the dropdown should show "🇬🇧 English (UK)", "🇺🇸 English (US)", "🇪🇸 Español", "🇫🇷 Français"
    And the dropdown should have a visible arrow button
    When I click on the dropdown
    Then the language list should appear
    And hovering over items should show a light gray background (not transparent)
    When I select a different language
    Then the selection should be highlighted in blue
    And the dropdown should close

  Scenario: JSON Tree Settings
    Given the preferences dialog is open
    When I look at the JSON Tree Settings section
    Then I should see a "Max Depth" checkbox labeled "Unlimited"
    And I should see a "Depth" setting with a horizontal slider
    And the slider should have a blue handle
    And there should be a number display showing the current value
    When I drag the slider
    Then the number display should update in real-time
    When I type a number in the display
    Then the slider position should update accordingly

  Scenario: Save Preferences
    Given the preferences dialog is open
    And I have changed the language to Spanish
    And I have set the depth to 5
    When I click the "Save" button
    Then the preferences should be saved
    And the dialog should close
    And the application language should change to Spanish
    And the JSON tree depth setting should be updated

  Scenario: Restore Defaults
    Given the preferences dialog is open
    And I have changed some settings
    When I click the "Restore Defaults" button
    Then all settings should return to their default values
    And the language should be "🇬🇧 English (UK)"
    And the depth should be 1
    And the "Unlimited" checkbox should be unchecked

  Scenario: Cancel Changes
    Given the preferences dialog is open
    And I have changed the language to French
    And I have changed the depth to 8
    When I close the dialog without saving
    Then the changes should not be applied
    And the application should remain in its previous state

  Scenario: Dialog Styling
    Given the preferences dialog is open
    When I examine the dialog appearance
    Then it should have a clean, modern design
    And the group boxes should have rounded corners
    And the buttons should have proper hover effects
    And the slider should have a professional blue theme
    And all text should be clearly readable
    And the layout should be well-organized

  Scenario: Keyboard Navigation
    Given the preferences dialog is open
    When I use the Tab key
    Then I should be able to navigate between all controls
    And the focus should be clearly visible
    When I press Enter on the Save button
    Then the preferences should be saved
    When I press Escape
    Then the dialog should close without saving
