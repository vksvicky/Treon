Feature: Internationalization (i18n)
  As a user
  I want to use the application in my preferred language
  So that I can understand the interface in my native language

  Background:
    Given the application supports the following languages:
      | Code  | Name           | Native Name |
      | en_GB | English (UK)   | English (UK)|
      | en_US | English (US)   | English (US)|
      | es    | Spanish        | Español     |
      | fr    | French         | Français    |
    And the default language is "en_GB"

  Scenario: User can see available languages in preferences
    Given the application is running
    When I open the preferences dialog
    Then I should see language selection with flag icons
    And I should see the following languages:
      | Language | Flag Icon |
      | English (UK) | 🇬🇧 |
      | English (US) | 🇺🇸 |
      | Español | 🇪🇸 |
      | Français | 🇫🇷 |

  Scenario: User can change language from preferences
    Given the application is running in English (UK)
    When I open the preferences dialog
    And I select "Français" from the language dropdown
    And I click "Save"
    Then the entire application should be in French
    And the menu bar should show French text
    And all dialog boxes should show French text
    And the landing screen should show French text
    And the preferences dialog should close

  Scenario: Application remembers language preference
    Given the application is running in French
    When I close the application
    And I restart the application
    Then the application should start in French
    And all interface elements should be in French

  Scenario: Application falls back to default language for unsupported system language
    Given the system language is set to German
    When I start the application
    Then the application should start in English (UK)
    And I should see a notification that German is not supported

  Scenario: Application handles missing translation files gracefully
    Given the French translation file is missing
    When I select French from the language dropdown
    Then the application should fall back to English (UK)
    And I should see an error message about the missing translation

  Scenario: User can change language without restarting
    Given the application is running in English (UK)
    When I change the language to Spanish in preferences
    Then the interface should immediately update to Spanish
    And I should not need to restart the application

  Scenario: All UI elements are translated
    Given the application is running in Spanish
    Then the menu bar should show:
      | Menu | Spanish Text |
      | File | Archivo |
      | Edit | Editar |
      | View | Ver |
      | Help | Ayuda |
    And all dialog titles should be in Spanish
    And all button labels should be in Spanish
    And all status messages should be in Spanish

  Scenario: Language selection persists across sessions
    Given I have previously selected French as my language
    When I start the application
    Then the application should start in French
    And the preferences should show French as selected
