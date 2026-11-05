# Java To-Do App: Portfolio Build Plan

## Goal and target roles

Build a small but production-style Java to-do app in about 6 weeks, fully covered by automated tests at every level, and publish it on GitHub as proof of skill for three kinds of roles.

| Role | What the project proves | Part they look at first |
| --- | --- | --- |
| QA / Test Automation Engineer | Test strategy, API and UI automation, CI, bug reporting | Test framework, reports, test plan |
| SDET | Both coding and testing, quality built into the pipeline | CI pipeline, test architecture |
| Junior Software Engineer | Clean Java code, REST API design, database | App code, structure, unit tests |

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
- Optional twist: present it as a "Job Application Tracker" (tasks = applications, statuses = Applied / Interview / Offer / Rejected). Same code, better story in interviews.

**Out of scope:** mobile app, real email notifications, payments, microservices. They add work without adding test value.

## Tech stack

The stack below matches what Dutch vacancies for Java developers and test automation engineers ask for in 2026: Java + Spring Boot on the dev side, and Java + REST Assured + Playwright (with Selenium and Cucumber) on the QA side.

| Area | Tool | Why for the NL market |
| --- | --- | --- |
| Language | Java 21 | NL ads ask for Java 17 or 21+ |
| Build | Maven | Named in most Dutch Java and QA ads |
| Framework | Spring Boot 3 (Web, Data JPA / Hibernate, Validation) | Core requirement in almost every NL Java vacancy, junior included |
| Database | PostgreSQL + Flyway | Relational DB and SQL are asked in both dev and QA ads |
| UI | Thymeleaf + Bootstrap | Keeps scope small; Angular or React is often a nice to have |
| API docs | springdoc OpenAPI (Swagger UI) | OpenAPI is standard in NL backend teams |
| Containers | Docker + docker-compose | Docker is standard; Kubernetes is often listed as a plus |
| Unit tests | JUnit 5, Mockito, AssertJ | JUnit is in nearly every Java ad |
| Integration tests | Spring Boot Test + Testcontainers | Real PostgreSQL in tests, valued in modern teams |
| API tests | REST Assured | Appears in nearly every Java QA ad in NL |
| Exploratory API testing | Postman collection | Often listed next to REST Assured |
| UI tests (main) | Playwright with TypeScript + Page Object Model | Most popular Playwright setup; NL QA ads often pair Playwright (TypeScript) with REST Assured (Java) |
| UI tests (second) | Selenium WebDriver 4 in Java (3 or 4 tests) | Still widely asked, so show you know both |
| BDD | Cucumber (Gherkin) | Frequently requested by Dutch banks, insurers and consultancies |
| Reports | Allure | Clear, visual test reports |
| Coverage | JaCoCo | Coverage badge for the README |
| CI/CD | GitHub Actions | GitHub Actions, Jenkins and Azure DevOps are all common; the concepts transfer |
| Performance (optional) | JMeter or Gatling | Shows non-functional testing |
| Cloud (optional) | Azure (App Service free tier) | Azure is very common in NL enterprises and government |
| AI tools | GitHub Copilot, Claude | Some NL QA ads now list Copilot and AI-assisted test generation |
| Way of working | GitHub Projects as a Scrum board | Scrum/Agile appears in almost every NL ad |

**Also worth knowing:** TestNG shows up in many QA ads next to JUnit; learn the differences for interviews. Some NL vacancies require Dutch; English-only roles are more common at international companies and consultancies.

## Roadmap

Six weeks at about 10 to 15 hours per week; each week ends with something working and pushed to GitHub. Exact build steps, API contract and test cases are in `development-plan.md`.

### Week 1: Setup and foundations

- [ ] Create GitHub repository, .gitignore, MIT license, short README stub
- [ ] Generate Spring Boot project (start.spring.io): Web, Data JPA, Validation, PostgreSQL, Flyway
- [ ] docker-compose with PostgreSQL; app connects to it
- [ ] Task entity, Flyway migration V1, repository
- [ ] First GitHub Actions workflow: build + run tests on every push
- [ ] Write a one-page test plan draft (scope, levels, tools)

**Done when:** app starts with one command and CI is green.

### Week 2: REST API and unit tests

- [ ] CRUD endpoints: GET /api/tasks, GET /api/tasks/{id}, POST, PUT, DELETE
- [ ] Filtering by status
- [ ] Validation and a global error handler with clear JSON errors (400, 404)
- [ ] Swagger UI via springdoc
- [ ] Unit tests for service layer with JUnit 5 + Mockito + AssertJ (happy paths and edge cases)
- [ ] Use parameterized tests for validation rules

**Done when:** all endpoints work in Swagger and service coverage is above 80%.

### Week 3: Web page and integration tests

- [ ] Thymeleaf page: task list with add, edit, delete and mark done
- [ ] Stable test hooks: data-testid attributes on key elements
- [ ] Integration tests with Testcontainers (real PostgreSQL)
- [ ] Controller tests with MockMvc for status codes and error bodies

**Done when:** the page works end to end and integration tests run in CI against a real database.

### Week 4: API test framework

- [ ] Separate module for API tests with REST Assured
- [ ] Base config (base URL, environments), request/response models (POJOs)
- [ ] Test data builders or factories, cleanup after each test
- [ ] Positive, negative and boundary tests for every endpoint
- [ ] JSON schema validation of responses and SQL checks of the data in PostgreSQL; a Postman collection for exploratory testing
- [ ] Allure reporting with steps and attachments
- [ ] Cucumber feature files for 3 to 5 key scenarios (often asked in NL ads)

**Done when:** API suite runs in CI and publishes an Allure report.

### Week 5: UI test framework

- [ ] List the UI flows to cover: add, edit, delete, mark done, filter, validation errors
- [ ] Add any missing data-testid attributes found while writing tests
- [ ] Learn TypeScript basics first (types, async/await, npm): 2 to 3 evenings
- [ ] Playwright TypeScript project in ui-tests/ with Page Object Model and fixtures
- [ ] Explicit waits only, no Thread.sleep
- [ ] 8 to 12 end-to-end tests for main user flows, plus 3 or 4 of them in Selenium (Java) to show both tools
- [ ] Headless run in CI, screenshot attached to Allure on failure

**Done when:** UI tests pass headless in CI and failures show screenshots.

### Week 6: Polish and presentation

- [ ] Pick 1 or 2 extras from App scope and test them
- [ ] Optional: JMeter or Gatling smoke performance test, or live deployment (see development-plan.md)
- [ ] Final test plan and test strategy document in /docs
- [ ] Log 3 to 5 realistic bugs as GitHub Issues (found and fixed during the project)
- [ ] Publish Allure report via GitHub Pages
- [ ] Finish README with badges, screenshots and how to run
- [ ] Update CV and LinkedIn (see Presentation)

**Done when:** a stranger can clone the repo, run it, and understand your testing approach in 5 minutes.

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

**Good practices interviewers look for:** independent tests with their own data, no hard-coded waits, readable test names (shouldReturn404WhenTaskDoesNotExist), config in properties files, no duplicated setup code.

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

Commit habits: small commits with clear messages, one feature branch and pull request per feature, so the history reads like real team work.

## Presentation

**README must contain**

- One-sentence description and a screenshot of the app
- Badges: CI status, coverage, Allure report link
- Tech stack list
- How to run: `docker compose up` and how to run each test suite
- Test strategy summary with the pyramid and test counts
- Link to the live Allure report (GitHub Pages)

**CV line (QA version)**

Built a Java test automation portfolio project: 100+ automated tests across unit, API (REST Assured), and UI (Playwright with TypeScript, Selenium, Page Object Model) levels, BDD with Cucumber, Testcontainers, Allure reporting and GitHub Actions CI. [GitHub link]

**CV line (developer version)**

Developed a Spring Boot REST application with PostgreSQL and Flyway, covered by unit, integration and end-to-end tests, containerized with Docker and deployed through GitHub Actions CI. [GitHub link]

**LinkedIn:** add it to Featured, and write one short post when it is finished.

**Interview questions to prepare**

1. Why Playwright in TypeScript but API tests in Java? Why REST Assured and Testcontainers?
2. Why is this check a unit test and not a UI test?
3. How do you keep tests independent and handle test data?
4. How do you deal with flaky UI tests?
5. Show me one bug you found and how you reported it.
6. What would you add next if this were a real product?

## Final checklist

- [ ] App runs with one command (docker compose up)
- [ ] CI is green and runs unit, integration, API and UI tests
- [ ] Allure report is published and linked from the README
- [ ] Coverage above 80% on the service layer
- [ ] Test plan and test strategy are in /docs
- [ ] 3 to 5 bug reports in GitHub Issues
- [ ] README has screenshots, badges and run instructions
- [ ] No secrets or passwords committed
- [ ] Link added to CV and LinkedIn Featured
- [ ] You can explain every tool choice in 2 sentences
