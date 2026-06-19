# Karate DSL API Automation Framework

![Karate DSL](https://img.shields.io/badge/Karate_DSL-1.3.1-brightgreen)
![Java](https://img.shields.io/badge/Java-8-orange)
![Maven](https://img.shields.io/badge/Maven-Build-red)
![JUnit 5](https://img.shields.io/badge/JUnit-5-25A162)
![Karate API Tests](https://github.com/Jiten20/karate-dsl-api-automation/actions/workflows/karate-tests.yml/badge.svg)

A maintainable API automation framework built using **Karate DSL**, **Java 8**, **Maven**, and **JUnit 5**. The project validates public REST APIs from the Restful Booker Platform and demonstrates positive and negative API testing, dynamic test-data creation, JSON validation, reusable configuration, HTML reporting, and GitHub Actions CI/CD.

**Application under test:** `https://automationintesting.online`

---

## 📁 Project Structure

```text
karate-dsl-api-automation/
│
├── .github/
│   └── workflows/
│       └── karate-tests.yml
│
├── src/
│   └── test/
│       └── java/
│           ├── karate-config.js
│           └── features/
│               ├── TestRunners.java
│               ├── getbrandinginformation.feature
│               ├── getlistavailablerooms.feature
│               └── bookroom.feature
│
├── target/
│   └── karate-reports/          ← Generated Karate HTML reports
│
├── .gitignore
├── pom.xml
└── README.md
```

---

## ✅ Test Results Summary

| Feature Suite | Scenarios | Passing | Failing |
| --- | ---: | ---: | ---: |
| Branding Verification | 1 | ✅ 1 | 0 |
| Room Inventory | 2 | ✅ 2 | 0 |
| Booking Creation | 4 | ✅ 4 | 0 |
| **Total** | **7** | ✅ **7** | **0** |

### Project at a Glance

| Metric | Count |
| --- | ---: |
| Feature files | **3** |
| Test scenarios | **7** |
| API resources covered | **3** |
| HTTP methods used | **2** |
| Positive scenarios | **4** |
| Negative scenarios | **3** |
| JUnit runner classes | **1** |

---

## 🧪 API Test Coverage

### 1. Branding Verification

**Endpoint:** `GET /api/branding`

| # | Validation | Status |
| --- | --- | --- |
| 1 | Verify HTTP status code is `200` | ✅ PASS |
| 2 | Verify branding name is returned correctly | ✅ PASS |
| 3 | Validate contact email using regex | ✅ PASS |

### 2. Room Inventory

**Endpoint:** `GET /api/room/`

| # | Scenario | Status |
| --- | --- | --- |
| 1 | Verify `rooms` is an array | ✅ PASS |
| 2 | Verify at least one room is returned | ✅ PASS |
| 3 | Verify every room has `roomPrice > 0` | ✅ PASS |

### 3. Booking Creation

**Endpoint:** `POST /api/booking`

| # | Scenario | Type | Status |
| --- | --- | --- | --- |
| 1 | Create a booking using a dynamically selected room ID | Positive | ✅ PASS |
| 2 | Reject a booking without `firstname` | Negative | ✅ PASS |
| 3 | Reject a booking when checkout is before check-in | Negative | ✅ PASS |
| 4 | Reject a booking without the expected Content-Type | Negative | ✅ PASS |

---

## ⚙️ Setup and Installation

### Prerequisites

- Java JDK 8
- Maven 3.x
- Git
- Internet access to the public test API

Verify the installations:

```bash
java -version
mvn -version
git --version
```

### Clone the Repository

```bash
git clone https://github.com/Jiten20/karate-dsl-api-automation.git
cd karate-dsl-api-automation
```

### Install Dependencies

Maven downloads all required dependencies automatically:

```bash
mvn clean test-compile
```

---

## 🚀 Running Tests

| Command | Description |
| --- | --- |
| `mvn clean test -Dtest=TestRunners` | Run the complete Karate test suite |
| `mvn clean test -Dtest=TestRunners -Dkarate.env=dev` | Run using the development environment |
| `mvn test -Dtest=TestRunners` | Run tests without deleting the existing `target` directory |

### Execute the Complete Suite

```bash
mvn clean test -Dtest=TestRunners
```

Expected successful result:

```text
Tests run: 7
Failures: 0
Errors: 0
Skipped: 0
BUILD SUCCESS
```

---

## 🌍 Environment Configuration

Environment configuration is centralized in:

```text
src/test/java/karate-config.js
```

Example:

```javascript
function fn() {
  var config = {
    baseURL: 'https://automationintesting.online'
  };

  var env = karate.env;

  if (env == 'dev') {
    config.baseURL = 'https://automationintesting.online';
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);
  }

  return config;
}
```

Run with an environment:

```bash
mvn clean test -Dtest=TestRunners -Dkarate.env=dev
```

Benefits:

- Centralized base URL
- Environment-specific configuration
- Reusable timeout settings
- No repeated URLs inside feature files

---

## 🏗️ Framework Design

### Combined JUnit 5 Runner

All feature files are executed through one JUnit 5 runner:

```java
package features;

import com.intuit.karate.junit5.Karate;

public class TestRunners {

    @Karate.Test
    Karate runAllApiTests() {
        return Karate.run(
                "getbrandinginformation",
                "getlistavailablerooms",
                "bookroom"
        ).relativeTo(getClass());
    }
}
```

Benefits:

- One command executes the full API suite
- One combined Karate summary report
- Easy Maven and CI/CD integration
- Centralized test-suite control

---

### Atomic Booking Scenarios

Each booking scenario retrieves a valid room ID before execution:

```karate
Given path '/api/room/'
When method GET
Then status 200

* def rooms = response.rooms
* def validRoom = rooms[0]
* def roomId = validRoom.roomid
```

Benefits:

- No dependency on another test
- Stable execution after environment resets
- Independent and repeatable scenarios
- Reduced hardcoded test data

---

### Dynamic Date Generation

Future booking dates are generated at runtime:

```karate
* def futureDate =
"""
function(days) {
  return java.time.LocalDate.now().plusDays(days).toString();
}
"""
```

Usage:

```karate
"checkin": "#(futureDate(2))",
"checkout": "#(futureDate(5))"
```

Benefits:

- Avoids expired hardcoded dates
- Makes tests reusable
- Supports repeated local and CI execution

---

## 🔍 Validation Techniques

| Validation | Karate Example |
| --- | --- |
| HTTP status | `Then status 200` |
| Exact value | `match response.name == 'Shady Meadows B&B'` |
| Data type | `match response.bookingid == '#number'` |
| Non-null value | `match response.bookingdates.checkin == '#notnull'` |
| Regular expression | `match email == '#regex ...'` |
| Array validation | `match response.rooms == '#[]'` |
| Non-empty array | `match response.rooms == '#[_ > 0]'` |
| Conditional validation | `match each response.rooms contains { roomPrice: '#? _ > 0' }` |
| Negative response | `match responseStatus != 201` |

---

## 📊 Reporting

Karate generates HTML reports automatically after test execution.

Open the main report:

```text
target/karate-reports/karate-summary.html
```

### Report Includes

- Feature-level results
- Scenario-level execution details
- Request and response information
- Assertion results
- Execution duration
- Tags and timeline reports
- Failed-step details

Generated reports are excluded from source control through `.gitignore`.

---

## 🔄 CI/CD Integration with GitHub Actions

The project uses GitHub Actions for continuous integration.

Workflow file:

```text
.github/workflows/karate-tests.yml
```

### Pipeline Triggers

The workflow executes when:

- Code is pushed to the `main` branch
- A pull request is opened against `main`
- The workflow is started manually from the Actions tab

### Pipeline Steps

1. Checkout the repository
2. Configure Temurin Java 8
3. Restore/cache Maven dependencies
4. Execute the Karate test suite
5. Generate Karate HTML reports
6. Upload the report as a GitHub Actions artifact

### Maven Command Used in CI

```bash
mvn -B clean test -Dtest=TestRunners
```

### Download the CI Report

After a workflow run:

1. Open the repository's **Actions** tab.
2. Select the completed **Karate API Tests** workflow.
3. Scroll to **Artifacts**.
4. Download `karate-api-test-report`.
5. Extract it and open `karate-summary.html`.

---

## 📝 `.gitignore`

```gitignore
# Maven
target/
*.log

# Eclipse
.classpath
.project
.settings/

# Java
*.class

# IDE
.idea/
*.iml

# OS files
.DS_Store
Thumbs.db
```

---

## 🛠️ Technology Stack

| Tool | Version / Purpose |
| --- | --- |
| Karate DSL | `1.3.1` — API test automation |
| Java | `8` — Runtime and helper functions |
| JUnit 5 | Test runner integration |
| Maven | Dependency management and execution |
| Maven Surefire | `2.22.2` — Test execution |
| GitHub Actions | CI/CD automation |
| Karate HTML Reporter | Native test reporting |
| Eclipse | Development IDE |

---

## 🚀 Future Enhancements

- Add smoke and regression tags
- Add reusable JSON schema files
- Add data-driven testing using Scenario Outline
- Add DEV, QA, and UAT environment profiles
- Add reusable authentication helpers
- Add parallel execution
- Add Docker-based execution
- Add Allure or Cucumber reporting
- Publish reports through GitHub Pages
- Add API contract validation
- Add performance-test coverage

---

## 📌 Key Highlights

- Karate DSL with Java 8
- Maven and JUnit 5 integration
- 3 API feature files
- 7 automated scenarios
- Positive and negative API testing
- Dynamic room ID extraction
- Runtime future-date generation
- Regex-based email validation
- JSON and array validation
- Independent atomic scenarios
- Native Karate HTML reporting
- GitHub Actions CI/CD
- Downloadable CI test-report artifacts
- Maintainable and reusable framework structure

---

## 👤 Author

**Jiten Motwani**

GitHub: [Jiten20](https://github.com/Jiten20)

---

## 📄 License

This project is created for learning and portfolio demonstration purposes.
