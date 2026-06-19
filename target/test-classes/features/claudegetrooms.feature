Feature: Room Inventory API Verification
  # Tests GET /room/ to confirm available rooms are returned with valid data.

  Background:
    * url baseURL

  Scenario: Room endpoint returns HTTP 200
    Given path '/room/'
    When method GET
    Then status 200

  Scenario: Response contains a "rooms" array with at least one entry
    Given path '/room/'
    When method GET
    Then status 200
    # Karate built-in: '#[]' asserts the value is an array
    And match response.rooms == '#[]'
    # '##[]' would allow empty; '#[_ > 0]' checks length is greater than 0
    And match response.rooms == '#[_ > 0]'

  Scenario: Every room has a roomPrice greater than zero
    Given path '/room/'
    When method GET
    Then status 200
    # '#each' iterates over every element in the array and applies the match
    And match each response.rooms contains { roomPrice: '#? _ > 0' }

  Scenario: Every room has the required fields with correct types
    Given path '/room/'
    When method GET
    Then status 200
    # Validate the schema of each room object using '#each'
    And match each response.rooms contains
    """
    {
      roomid:    '#number',
      roomName:  '#string',
      type:      '#string',
      accessible: '#boolean',
      roomPrice: '#number'
    }
    """

  Scenario: Capture a valid roomid for downstream booking tests
    Given path '/room/'
    When method GET
    Then status 200
    # Store the first room's ID in a Karate variable so other features can reuse it
    * def firstRoom  = response.rooms[0]
    * def validRoomId = firstRoom.roomid
    # Confirm it is a positive integer
    And match validRoomId == '#number'
    And assert validRoomId > 0
    # Print to Karate log for traceability
    * print 'Captured roomId for booking tests:', validRoomId
