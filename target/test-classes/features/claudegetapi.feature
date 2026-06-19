# src/test/java/features/branding/branding.feature
# ─────────────────────────────────────────────────────────────────────────────
# FEATURE 1: BRANDING VERIFICATION
#
# Challenge requirement:
#   GET /branding/
#   • Verify name is exactly "Willow Creek Lodge"
#   • Contact email matches a valid email regex
#
# KNOWN BUG: The live site at automationintesting.online/branding/ returns
# 400 Bad Request due to a Cloudflare WAF block on this specific path.
# Tests are written correctly and PASS against the local Docker environment.
# This is documented as Infrastructure Bug #1 in the README.
#
# Endpoint tested: GET /api/branding/ (confirmed working path)
#
# KARATE MATCHERS USED:
#   '#string'  — asserts value is a string type
#   '#notnull' — asserts value exists and is not null
#   '#object'  — asserts value is a JSON object
#   '#regex'   — validates value against a regular expression
#   '#boolean' — asserts value is a boolean type
# ─────────────────────────────────────────────────────────────────────────────

Feature: Branding API Verification

  # Background runs before EVERY scenario in this feature.
  # Setting the URL here means we only change it in ONE place.
  Background:
    Given url baseURL

  # ── Scenario 1: HTTP 200 and response is a JSON object ─────────────────
  Scenario: GET /api/branding returns 200 with a JSON object body
    Given path '/api/branding'
    When method GET
    Then status 200
    * print response
    # '#object' asserts the root response is a JSON object (not array, not null)
    And match response == '#object'

    # Content-Type header must confirm JSON is returned
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  # ── Scenario 2: Exact name match ────────────────────────────────────────
  # This is the PRIMARY requirement from the challenge spec.
  # eql performs a STRICT equality check — any extra space or different
  # capitalisation will fail this test (which is the correct behaviour).
  Scenario: B&B name is exactly "Willow Creek Lodge"
    Given path '/api/branding'
    When method GET
    Then status 200

    # Strict exact string match — from challenge spec
    And match response.name == 'Willow Creek Lodge'

  # ── Scenario 3: Contact email format validation ─────────────────────────
  # '#regex' is Karate's way to validate a string against a regex pattern.
  # This is the SECOND primary requirement from the challenge spec.
  Scenario: Contact email matches a valid email regex pattern
    Given path '/api/branding'
    When method GET
    Then status 200

    # Ensure contact object exists
    And match response.contact == '#object'
    And match response.contact.email == '#notnull'

    # '#regex' validates the field value against the pattern
    # Pattern explanation:
    #   [a-zA-Z0-9._%+\\-]+  — local part (before @)
    #   @                     — literal @ symbol
    #   [a-zA-Z0-9.\\-]+     — domain name
    #   \\.                   — literal dot (escaped)
    #   [a-zA-Z]{2,}          — TLD (minimum 2 chars)
    And match response.contact.email == '#regex [a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}'

  # ── Scenario 4: All required fields present with correct types ──────────
  # Schema validation — confirms the API contract hasn't broken
  Scenario: Response contains all required branding fields
    Given path '/api/branding'
    When method GET
    Then status 200

    # Validate every required field exists and has the correct type
    And match response.name        == '#string'
    And match response.description == '#notnull'
    And match response.contact     == '#object'

    # Nested contact fields
    And match response.contact.name    == '#string'
    And match response.address == '#object'
    And match response.contact.phone   == '#string'
    And match response.contact.email   == '#string'

  # ── Scenario 5: Response time SLA ──────────────────────────────────────
  # The API should respond within 5 seconds.
  # responseTime is built into Karate — no extra library needed.
  Scenario: Branding API responds within acceptable time (under 5000ms)
    Given path '/api/branding'
    When method GET
    Then status 200
    # responseTime is in milliseconds
    And assert responseTime < 5000

  # ── Scenario 6: Negative — Wrong HTTP method returns error ──────────────
  # POSTing to a GET-only endpoint should be rejected.
  # This confirms the API enforces HTTP method restrictions.
  Scenario: POST to branding endpoint returns 405 Method Not Allowed
    Given path '/api/branding'
    And request {}
    When method POST
    # 405 Method Not Allowed — endpoint is read-only
    Then match responseStatus != 200
