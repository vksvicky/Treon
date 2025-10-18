Feature: Translation System
  As a user
  I want the application to display text in my preferred language
  So that I can use the application in my native language

  Background:
    Given the application is installed with translation files
    And the following languages are available: "en_GB", "en_US", "es", "fr"

  Scenario: Application starts with saved language preference
    Given the user previously selected "es" as their language
    When the application launches
    Then the application should display all text in Spanish
    And the menu items should show Spanish text
    And the landing screen should show Spanish text
    And the preferences dialog should show Spanish text

  Scenario: Application starts with no saved language preference
    Given no language preference is saved
    When the application launches
    Then the application should detect the system language
    And display text in the detected language if supported
    Or fall back to "en_GB" if system language is not supported

  Scenario: User changes language in preferences
    Given the application is running in English
    When the user opens preferences
    And selects "fr" as the language
    And clicks "Save"
    Then the preferences dialog should close
    And all application text should immediately update to French
    And the menu items should show French text
    And the landing screen should show French text
    And the language preference should be saved for next session

  Scenario: Language change affects all UI components
    Given the application is running
    When the user changes the language to "es"
    Then the following should be translated:
      | Component | English Text | Spanish Text |
      | Menu Bar | "File" | "Archivo" |
      | Menu Bar | "Help" | "Ayuda" |
      | Menu Item | "New" | "Nuevo" |
      | Menu Item | "Open..." | "Abrir..." |
      | Menu Item | "About Treon" | "Acerca de Treon" |
      | Menu Item | "Preferences..." | "Preferencias..." |
      | Landing Screen | "Open File" | "Abrir Archivo" |
      | Landing Screen | "New File" | "Nuevo Archivo" |
      | Landing Screen | "From Pasteboard" | "Desde Portapapeles" |
      | Landing Screen | "From URL" | "Desde URL" |
      | Landing Screen | "From cURL" | "Desde cURL" |
      | Landing Screen | "Recent Files" | "Archivos Recientes" |
      | Landing Screen | "Drag and drop a JSON file here" | "Arrastra y suelta un archivo JSON aquí" |

  Scenario: Translation system handles missing translations gracefully
    Given a translation file is missing some strings
    When the application tries to display a missing translation
    Then it should fall back to the English text
    And log a warning about the missing translation
    And continue to function normally

  Scenario: Translation system works with native C++ menus
    Given the application uses native C++ menus
    When the language is changed to "fr"
    Then the native menu items should be translated to French
    And the menu shortcuts should remain functional
    And the menu actions should work correctly

  Scenario: Translation system works with QML components
    Given the application has QML components
    When the language is changed to "es"
    Then all QML text should be translated to Spanish
    And the QML components should update immediately
    And no English text should remain visible
