Feature: Basic JSON validation
  As a Treon developer
  I want structural validation of JSON strings
  So that I can guard expensive parsing early

  Scenario: Validate simple object
    Given the JSON string "{\"k\":1}"
    When I validate the JSON
    Then the result should be valid

  Scenario: Reject bare literal
    Given the JSON string "true"
    When I validate the JSON
    Then the result should be invalid

