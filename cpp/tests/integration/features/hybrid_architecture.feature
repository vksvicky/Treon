Feature: Hybrid C++/QML Architecture
  As a user of Treon
  I want a native macOS menu system with rich QML content
  So that I get the best of both native performance and modern UI capabilities

  Background:
    Given the application is running with hybrid C++/QML architecture
    And the native C++ menu bar is visible
    And the QML content is loaded and displayed

  Scenario: Native Menu Bar Integration
    Given the application is launched
    When I look at the menu bar
    Then I should see a native macOS menu bar
    And the menu bar should contain "File", "Help" menus
    And the application menu should contain "About Treon", "Preferences", "Quit Treon"
    And there should be no duplicate menu items

  Scenario: Menu Shortcuts Work
    Given the application is running
    When I press "Cmd+," (Preferences)
    Then the preferences dialog should open
    When I press "Cmd+N" (New)
    Then a new file should be created
    When I press "Cmd+O" (Open)
    Then the file open dialog should appear
    When I press "Cmd+S" (Save)
    Then the current file should be saved
    When I press "Cmd+Q" (Quit)
    Then the application should quit

  Scenario: Menu Actions Communicate with QML
    Given the application is running with a JSON file loaded
    When I click "File" > "New" from the menu
    Then the QML application should create a new file
    And the QML content should update to show the new file state
    When I click "File" > "Open..." from the menu
    Then the QML file dialog should open
    When I click "File" > "Save" from the menu
    Then the QML application should save the current file

  Scenario: Preferences Integration
    Given the application is running
    When I click "Treon" > "Preferences..." from the menu
    Then the C++ preferences dialog should open
    And I should be able to change language settings
    And I should be able to adjust JSON tree depth with a slider
    And the changes should be applied to the QML content
    When I click "Save" in the preferences dialog
    Then the preferences should be saved
    And the dialog should close

  Scenario: About Dialog Integration
    Given the application is running
    When I click "Treon" > "About Treon" from the menu
    Then the QML about dialog should open
    And it should display application information
    When I close the about dialog
    Then I should return to the main application

  Scenario: Translation System Integration
    Given the application is running
    When I open preferences and change the language to Spanish
    And I save the preferences
    Then the QML content should update to Spanish
    And the native menu items should remain functional
    When I change the language to French
    And I save the preferences
    Then the QML content should update to French
    And all menu actions should continue to work

  Scenario: File Operations Through Native Menus
    Given the application is running
    When I click "File" > "Open..." from the menu
    And I select a JSON file
    Then the QML application should load the file
    And the QML content should display the JSON structure
    When I click "File" > "Save As..." from the menu
    And I choose a location
    Then the QML application should save the file
    And the file should be saved successfully

  Scenario: Error Handling
    Given the application is running
    When I try to open an invalid JSON file
    Then the QML application should show an error message
    And the native menu should remain functional
    When I try to save to a read-only location
    Then the QML application should show an appropriate error
    And the application should not crash
