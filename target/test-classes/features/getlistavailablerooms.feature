Feature: Room Inventory

  # Background runs before EVERY scenario in this feature.
  # Setting the URL here means we only change it in ONE place.
  Background: 
    Given url baseURL

  Scenario: Verify response is an array
    Given path '/api/room/'
    When method GET
    Then status 200
    * print response
    # Karate built-in: '#[]' asserts the value is an array
    And match response.rooms == '#[]'
    # '##[]' would allow empty; '#[_ > 0]' checks length is greater than 0
    And match response.rooms == '#[_ > 0]'

  Scenario: Verify room length is greater than zero
    Given path '/api/room/'
    When method GET
    Then status 200
    * print response
    # '#each' iterates over every element in the array and applies the match
    And match each response.rooms contains { roomPrice: '#? _ > 0' }
