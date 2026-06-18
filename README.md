# Karate DSL API Automation Framework

This project demonstrates API automation testing using Karate DSL, Java 8, Maven and JUnit 5.

## Technologies

* Java 8
* Karate DSL 1.3.1
* Maven
* JUnit 5
* Eclipse

## APIs Covered

### Branding API

* Sends a GET request to retrieve branding information.
* Validates the HTTP status code.
* Validates response values.
* Validates the email format using a regular expression.

### Room Inventory API

* Retrieves the available room inventory.
* Verifies that the rooms response is an array.
* Verifies that at least one room is available.
* Verifies that at least one room has a price greater than zero.

### Booking API

* Dynamically retrieves a valid room ID.
* Creates a booking using future check-in and checkout dates.
* Verifies the generated booking ID.
* Verifies the booking response details.
* Includes negative test scenarios for invalid booking requests.

## Running the Tests

Run all tests using Maven:

```bash
mvn clean test -Dtest=TestRunners
```

## Test Report

After execution, the Karate HTML report is generated at:

```text
target/karate-reports/karate-summary.html
```

## Framework Highlights

* Independent and atomic test scenarios
* Dynamic test-data generation
* Positive and negative API testing
* JSON response and schema validation
* Karate HTML reporting
* Maven-based test execution
