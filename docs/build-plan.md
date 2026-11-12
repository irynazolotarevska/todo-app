# Java To-Do App: Build Plan

## Goal

Build a small but production-style Java to-do app, fully covered by automated tests at every level: unit, integration, API and UI, all running in CI with published reports.

Rule of thumb: keep the app simple, make the engineering around it excellent. A finished small project beats an unfinished big one.

## App scope

The MVP is a REST API plus a simple web UI for a single task list with no login; login and other extras are added only after the MVP is fully tested.

**MVP (must have)**

- Create, view, edit and delete a task
- Task fields: title (required), description, status (To do / Done), due date
- Filter by status
- Validation with clear error messages (empty title, title over 100 characters)
- One simple web page: task list with add, edit, delete and mark done

**Extras (nice to have, pick 2 or 3)**

- Login and registration, each user sees only their own tasks (great for security tests)
- More statuses (In progress) and priority (Low / Medium / High)
- Sorting by due date and search by text
- Tags or categories
- Pagination for long lists
- Overdue tasks highlighted

**Out of scope:** mobile app, real email notifications, payments, microservices. They add work without adding test value.

## Tech stack

A common, modern Java stack for web applications and test automation.

| Area | Tool | Why |
| --- | --- | --- |
| Language | Java 21 | Current LTS version with records and modern language features |
| Build | Maven | Standard Java build tool; multi-module support for the test suites |
| Framework | Spring Boot 4 (Web, Data JPA / Hibernate, Validation) | Production-ready REST API with little boilerplate |
| Database | PostgreSQL + Flyway | Real relational database; versioned, repeatable schema migrations |
| UI | Thymeleaf + Bootstrap | Server-side page keeps the scope small |
| API docs | springdoc OpenAPI (Swagger UI) | Documentation generated from the code, and a quick way to try the API |
| Containers | Docker + docker-compose | The same setup locally and in CI |
| Unit tests | JUnit 5, Mockito, AssertJ | Fast tests for business rules; readable assertions |
| Integration tests | Spring Boot Test + Testcontainers | Real PostgreSQL in tests, no mocks for the database |
| API tests | REST Assured | Black-box tests of the HTTP contract, separate from the app code |
| Exploratory API testing | Postman collection | Manual checks and shareable example requests |
| UI tests (main) | Playwright with TypeScript + Page Object Model | Fast, reliable browser tests with auto-waits |
| UI tests (second) | Selenium WebDriver 4 in Java (3 or 4 tests) | The same flows with a second, widely used tool |
| BDD | Cucumber (Gherkin) | Key scenarios readable by non-developers |
| Reports | Allure | Clear, visual test reports with steps and attachments |
| Coverage | JaCoCo | Measures what the tests cover; coverage badge for the README |
| CI/CD | GitHub Actions | Every push builds and runs all test suites |
| Performance (optional) | JMeter or Gatling | Non-functional smoke check of response times |
| Cloud (optional) | Azure App Service or Render | A live demo link |
| Way of working | GitHub Issues + Projects | Epics and tasks tracked like in a real team |

## Roadmap

The work is split into **epics**. Each epic delivers one complete feature that can be demonstrated, with its tests, so the app is always working and always tested. Tasks, subtasks, test cases and the Definition of Done for every epic are in `development-plan.md`, the single source of truth for the build order.

| Epic | Feature | Logical end: "you can now…" |
| --- | --- | --- |
| E0 | Foundation | …start the app; table, entity, repository and DTOs are ready |
| E1 | Create and view tasks | …create a task and see it; bad input gives 400, unknown id gives 404 |
| E2 | API test framework | …run black-box API tests for everything that exists, in CI |
| E3 | Edit and mark done | …change a task and mark it DONE |
| E4 | Delete | …delete a task: full CRUD works |
| E5 | Filter by status | …filter tasks: API MVP complete |
| E6 | Web page + Playwright | …do everything in the browser, with UI tests |
| E7 | Selenium | …run a few UI checks with a second tool |
| E8 | Reports and release | …show a finished `v1.0.0` with published reports |

After the MVP: optionally pick 1 or 2 extras from App scope, a performance smoke test, or a live deployment.

**Done when:** a stranger can clone the repo, run it, and understand the testing approach in 5 minutes.

## Test strategy

Follow the test pyramid: many fast unit tests, fewer API and integration tests, and a small set of UI tests for the main user journeys. Full test cases, entry and exit criteria, and defect rules are in `test-plan.md`.

| Level | Tools | What it checks | Target size | Runs |
| --- | --- | --- | --- | --- |
| Unit | JUnit 5, Mockito, AssertJ | Business rules, validation, mapping | 40 to 60 tests, under 10 s | Every push |
| Integration | Spring Boot Test, Testcontainers, MockMvc | Repository queries, controllers, migrations | 15 to 25 tests | Every push |
| API | REST Assured, Allure | Contract, status codes, schemas, negative and boundary cases | 25 to 40 tests | Every push |
| UI / E2E | Playwright (TypeScript) + a few Selenium (Java), Page Objects | Create, edit, mark done, filter, delete flows | 8 to 12 tests | Every push (headless) |
| Performance (optional) | Gatling or JMeter | Response time of list and create endpoints | 1 to 2 scenarios | Manual or nightly |

**Test design techniques:** equivalence partitioning, boundary value analysis (title length 0, 1, 100, 101), decision tables for filters, negative testing, state transitions for task status.

**Good practices:** independent tests with their own data, no hard-coded waits, readable test names (shouldReturn404WhenTaskDoesNotExist), config in properties files, no duplicated setup code.

## Repository structure

```
todo-app/
  app/                      Spring Boot application (Java)
    src/main/java/.../      controller, service, repository, model, dto, exception
    src/main/resources/     application.yml, db/migration, templates
    src/test/java/.../      unit + integration tests (Testcontainers)
  api-tests/                REST Assured + Cucumber + Allure (Java)
  ui-tests/                 Playwright + TypeScript (pages/, tests/)
  selenium-tests/           3 or 4 Selenium tests (Java)
  perf-tests/               optional JMeter or Gatling scenarios
  docs/                     plans, test strategy, screenshots
  .github/workflows/        ci.yml (Java jobs + Node job for Playwright)
  docker-compose.yml
  pom.xml                   parent POM
  README.md
```

Commit habits: small commits with clear messages, one feature branch and pull request per epic, so the history reads like real team work.

## README must contain

- One-sentence description and a screenshot of the app
- Badges: CI status, coverage, Allure report link
- Tech stack list
- How to run: `docker compose up` and how to run each test suite
- Test strategy summary with the pyramid and test counts
- Link to the live Allure report (GitHub Pages)

## Final checklist

- [ ] App runs with one command (docker compose up)
- [ ] CI is green and runs unit, integration, API and UI tests
- [ ] Allure report is published and linked from the README
- [ ] Coverage above 80% on the service layer
- [ ] Test plan and test strategy are in /docs
- [ ] 3 to 5 bug reports in GitHub Issues
- [ ] README has screenshots, badges and run instructions
- [ ] No secrets or passwords committed
