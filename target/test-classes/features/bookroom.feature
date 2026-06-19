Feature: Booking Creation

  # Tests POST /booking/ — creates a booking after first fetching a valid roomid.
  # Each scenario is ATOMIC: it fetches its own roomid so it never depends on
  # prior test state. This is critical because the platform resets every 10 min.
  Background: 
    * url baseURL
    # Step 1: Dynamically obtain a valid roomid before every scenario
    Given path '/api/room/'
    When method GET
    Then status 200
    * def rooms = response.rooms
    * def validRoom = rooms[0]
    * def roomId = validRoom.roomid
    * print 'Using roomId:', roomId
    # Reusable helper: build a future date string offset by N days from today
    * def today = function(){ return java.time.LocalDate.now().toString() }
    * def futureDate = function(n){ return java.time.LocalDate.now().plusDays(n).toString() }

  Scenario: Successfully create a booking and receive a 201 response
    Given path '/api/booking'
    And header Content-Type = 'application/json'
    And request
      """
      {
      	"roomid": #(roomId),
        "firstname":   "Test",
        "lastname":    "Automation",
        "totalprice":  150,
        "depositpaid": true,
        "bookingdates": {
          "checkin":  "#(futureDate(2))",
          "checkout": "#(futureDate(5))"
        },
        "additionalneeds": "Karate DSL test booking"
      }
      """
    # NOTE: The /booking/ endpoint wraps the room in a nested object.
    # We post to the platform booking service which also accepts the roomid header.
    #And header roomid = roomId
    When method POST
    Then status 201
    # Validate the booking was created with a server-generated ID
    And match response.bookingid == '#number'
    And assert response.bookingid > 0
    * print response
    # Validate the echoed booking details match what we sent
    And match response.firstname   == 'Test'
    And match response.lastname    == 'Automation'
    And match response.depositpaid == true
    And match response.bookingdates.checkin  == '#notnull'
    And match response.bookingdates.checkout == '#notnull'
    # Store bookingid for potential chained scenarios (read-only here)
    * def createdBookingId = response.bookingid
    * print 'Booking created with ID:', createdBookingId

  # ─── Negative Tests ──────────────────────────────────────────────────────────
  Scenario: Booking without required firstname returns 400 or validation error
    Given path '/api/booking'
    And header Content-Type = 'application/json'
    And header roomid = roomId
    And request
      """
          {
            "lastname":    "NoFirstname",
            "totalprice":  100,
            "depositpaid": true,
            "bookingdates": {
              "checkin":  "#(futureDate(1))",
              "checkout": "#(futureDate(3))"
            }
          }
      """
    When method POST
    # Platform should reject an incomplete payload
    Then match responseStatus != 201

  Scenario: Booking with checkout before checkin returns an error
    Given path '/api/booking'
    And header Content-Type = 'application/json'
    And header roomid = roomId
    And request
      """
      {
        "firstname":   "Bad",
        "lastname":    "Dates",
        "totalprice":  100,
        "depositpaid": true,
        "bookingdates": {
          "checkin":  "#(futureDate(5))",
          "checkout": "#(futureDate(2))"
        }
      }
      """
    When method POST
    # Business rule: checkout must be after checkin
    Then match responseStatus != 201

  Scenario: Booking without Content-Type header returns an error
    Given path '/api/booking'
    # Intentionally omitting Content-Type to test server-side validation
    And header roomid = roomId
    And request '{"firstname":"NoHeader","lastname":"Test","depositpaid":true,"bookingdates":{"checkin":"2025-12-01","checkout":"2025-12-05"}}'
    When method POST
    Then match responseStatus != 201
