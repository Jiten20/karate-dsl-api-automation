Feature: Branding Verification

  Scenario: Validate that the B&B branding information (name, contact details, and descriptions) is returning correctly.
    configure headers ={content-type: "application/json", Connection: "keep-alive" }

    Given url baseURL + '/api/branding'
    When method GET
    Then status 200
    * print response
    * def jsonresponse = response
    * def validatename = jsonresponse.name
    * def validateemailformat = jsonresponse.contact.email
    * match validatename == 'Shady Meadows B&B'
    * match validateemailformat == '#regex ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z]{2,}$'
