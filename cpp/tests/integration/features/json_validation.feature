Feature: JSON Validation
  As a user of the Treon JSON viewer
  I want to validate JSON content
  So that I can ensure the data is properly formatted

  Background:
    Given the Treon application is running
    And I have opened a JSON file or entered JSON content

  Scenario: Validate valid JSON object
    Given I have entered the following valid JSON:
      """
      {
        "name": "John Doe",
        "age": 30,
        "email": "john@example.com",
        "active": true
      }
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"
    And the notification should have a green background
    And the JSON tree should be updated with the content

  Scenario: Validate valid JSON array
    Given I have entered the following valid JSON:
      """
      [
        {
          "id": 1,
          "name": "Item 1"
        },
        {
          "id": 2,
          "name": "Item 2"
        }
      ]
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"
    And the JSON tree should show the array structure

  Scenario: Validate empty JSON object
    Given I have entered the following valid JSON:
      """
      {}
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"

  Scenario: Validate empty JSON array
    Given I have entered the following valid JSON:
      """
      []
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"

  Scenario: Validate complex nested JSON
    Given I have entered the following valid JSON:
      """
      {
        "users": [
          {
            "id": 1,
            "name": "John Doe",
            "profile": {
              "age": 30,
              "city": "New York",
              "interests": ["programming", "music"]
            }
          }
        ],
        "metadata": {
          "total": 1,
          "page": 1
        }
      }
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"
    And the JSON tree should show the nested structure

  Scenario: Validate invalid JSON with missing closing brace
    Given I have entered the following invalid JSON:
      """
      {
        "name": "John Doe",
        "age": 30
      """
    When I click the "Validate" button
    Then I should see an error notification
    And the notification should have the title "JSON Validation Error"
    And the notification should contain an error message
    And the notification should have a red background
    And the error line should be highlighted in the text editor
    And the cursor should be positioned at the error location

  Scenario: Validate invalid JSON with trailing comma
    Given I have entered the following invalid JSON:
      """
      {
        "name": "John Doe",
        "age": 30,
      }
      """
    When I click the "Validate" button
    Then I should see an error notification
    And the notification should have the title "JSON Validation Error"
    And the notification should contain an error message
    And the error line should be highlighted in the text editor

  Scenario: Validate invalid JSON with unquoted key
    Given I have entered the following invalid JSON:
      """
      {
        name: "John Doe",
        "age": 30
      }
      """
    When I click the "Validate" button
    Then I should see an error notification
    And the notification should have the title "JSON Validation Error"
    And the notification should contain an error message
    And the error line should be highlighted in the text editor

  Scenario: Validate invalid JSON with unterminated string
    Given I have entered the following invalid JSON:
      """
      {
        "name": "John Doe,
        "age": 30
      }
      """
    When I click the "Validate" button
    Then I should see an error notification
    And the notification should have the title "JSON Validation Error"
    And the notification should contain an error message
    And the error line should be highlighted in the text editor

  Scenario: Validate empty content
    Given I have entered empty content
    When I click the "Validate" button
    Then I should see an error notification
    And the notification should have the title "JSON Validation Error"
    And the notification should contain an error message

  Scenario: Clear error highlighting after fixing JSON
    Given I have entered the following invalid JSON:
      """
      {
        "name": "John Doe,
        "age": 30
      }
      """
    And I have clicked the "Validate" button
    And I can see the error notification and highlighting
    When I fix the JSON by adding the missing quote:
      """
      {
        "name": "John Doe",
        "age": 30
      }
      """
    And I click the "Validate" button
    Then I should see a success notification
    And the error highlighting should be cleared
    And the cursor should be positioned normally

  Scenario: Validate JSON with special characters
    Given I have entered the following valid JSON with special characters:
      """
      {
        "path": "C:\\Users\\John",
        "regex": "\\d+",
        "quotes": "\"hello\"",
        "unicode": "你好世界",
        "emoji": "😀"
      }
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"

  Scenario: Validate JSON with all data types
    Given I have entered the following valid JSON with all data types:
      """
      {
        "string": "hello world",
        "number": 42,
        "float": 3.14159,
        "boolean_true": true,
        "boolean_false": false,
        "null_value": null,
        "array": [1, 2, 3],
        "object": {"nested": "value"}
      }
      """
    When I click the "Validate" button
    Then I should see a success notification
    And the notification should say "JSON is valid!"
    And the JSON tree should display all data types correctly
