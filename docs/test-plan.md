# Test Plan: To-Do App MVP

This plan defines what is tested, how, where and when for the To-Do App MVP. It follows a light ISTQB structure.

| Item | Value |
| --- | --- |
| Product | To-Do App (REST API + web page) |
| Version | MVP, v0.1 |
| Author | Iryna |
| Status | Draft |

## 1. Scope

**In scope**

- REST API: create, view, edit, mark done, delete, filter tasks
- Input validation and error responses
- Web page: all MVP actions in the browser
- Database persistence and migrations
- CI execution and reporting

**Out of scope (MVP)**

- Login and authorization (planned extra)
- Cross-browser testing beyond Chromium (Selenium runs Chrome only)
- Mobile layouts, accessibility audit, security testing, load testing beyond a smoke check

## 2. Requirements under test

| ID | Requirement |
| --- | --- |
| R1 | A user can create a task with a title, optional description and optional due date; new tasks start as TODO |
| R2 | A user can see all tasks and open a single task |
| R3 | A user can edit a task's title, description, status and due date |
| R4 | A user can mark a task as DONE |
| R5 | A user can delete a task |
| R6 | A user can filter tasks by status |
| R7 | Invalid input is rejected with a clear error message and no data is changed |

## 3. Test approach

| Level | Goal | Tools |
| --- | --- | --- |
| Unit | Business rules and validation in isolation | JUnit 5, Mockito, AssertJ |
| Integration | Database, migrations and controllers with a real PostgreSQL | Spring Boot Test, Testcontainers, MockMvc |
| API | Contract, status codes, schemas, negative and boundary cases, data in the database | REST Assured, Cucumber, SQL checks |
| UI / E2E | Main user flows in the browser | Playwright (TypeScript), Selenium (Java) |
| Exploratory | Find what scripts miss | Time-boxed sessions with charters |

**Test design techniques:** equivalence partitioning, boundary value analysis, state transition (TODO to DONE and back), error guessing.

**Test suites**

- **Smoke** (tag `@smoke`): TC-01, TC-11, TC-19, TC-24, TC-27. Runs first in CI, stops the pipeline if it fails.
- **Regression:** all automated tests, on every push to `main` and every pull request.

## 4. Test cases

| ID | Test case | Req | Level | Priority | Automated in |
| --- | --- | --- | --- | --- | --- |
| TC-01 | Create task with title only: 201, status TODO, createdAt set | R1 | API | High | REST Assured |
| TC-02 | Create task with all fields: 201, values returned and stored | R1 | API + DB | High | REST Assured |
| TC-03 | Create task with empty title: 400, field error on title | R7 | API | High | REST Assured |
| TC-04 | Create task with title of only spaces: 400 | R7 | Unit + API | Medium | JUnit, REST Assured |
| TC-05 | Title of 1 character: 201 | R7 | API | Medium | REST Assured |
| TC-06 | Title of exactly 100 characters: 201 | R7 | API | High | REST Assured |
| TC-07 | Title of 101 characters: 400 | R7 | API | High | REST Assured |
| TC-08 | Description of 500 characters: 201; 501 characters: 400 | R7 | API | Medium | REST Assured |
| TC-09 | Due date in wrong format (01-12-2026): 400 | R7 | API | Medium | REST Assured |
| TC-10 | Malformed JSON body: 400 in the standard error shape | R7 | API | Medium | REST Assured |
| TC-11 | Get task by id: 200, body matches schema | R2 | API | High | REST Assured |
| TC-12 | Get unknown id: 404 in the standard error shape | R2 | API | High | REST Assured |
| TC-13 | List all tasks: 200, contains created tasks | R2 | API | High | REST Assured |
| TC-14 | Update all fields: 200, new values in the database | R3 | API + DB | High | REST Assured + SQL |
| TC-15 | Update unknown id: 404 | R3 | API | Medium | REST Assured |
| TC-16 | Update with invalid title: 400, database row unchanged | R3, R7 | API + DB | Medium | REST Assured + SQL |
| TC-17 | Mark task DONE: 200, status DONE | R4 | API | High | REST Assured, Cucumber |
| TC-18 | Invalid status value ("OPEN"): 400 | R4, R7 | API | Medium | REST Assured |
| TC-19 | Delete task: 204, then GET returns 404 | R5 | API | High | REST Assured, Cucumber |
| TC-20 | Delete unknown id: 404 | R5 | API | Medium | REST Assured |
| TC-21 | Filter by DONE returns only DONE tasks | R6 | API | High | REST Assured |
| TC-22 | Filter with no matching tasks: 200, empty list | R6 | API | Low | REST Assured |
| TC-23 | Filter by unknown status: 400 | R6, R7 | API | Low | REST Assured |
| TC-24 | Add task in the form: it appears in the list as TODO | R1 | UI | High | Playwright, Selenium |
| TC-25 | Submit empty title: error message shown, no task added | R7 | UI | High | Playwright |
| TC-26 | Edit task title: new title shown in the list | R3 | UI | Medium | Playwright |
| TC-27 | Mark task done: status changes to DONE | R4 | UI | High | Playwright, Selenium |
| TC-28 | Delete task: row disappears | R5 | UI | High | Playwright, Selenium |
| TC-29 | Filter dropdown shows only matching tasks | R6 | UI | Medium | Playwright |
| TC-30 | No tasks: empty state message shown | R2 | UI | Low | Playwright |
| TC-31 | Due date shown in the expected format | R2 | UI | Low | Playwright |
| TC-32 | Clean database: Flyway creates the tasks table | R2 | Integration | High | Testcontainers |
| TC-33 | Repository findByStatus returns the right rows | R6 | Integration | Medium | Testcontainers |

**Traceability:** every requirement R1 to R7 has at least two test cases, at API and UI level.

**Exploratory charters** (45 minutes each, notes saved in `docs/exploratory/`)

1. Explore titles with special characters, emoji, HTML tags and other languages, to discover display and encoding problems.
2. Explore fast repeated actions (double-click submit, delete twice) to discover duplicate or broken data.
3. Explore very long descriptions and many tasks to discover layout problems on the page.

## 5. Test environment

| Component | Version |
| --- | --- |
| App | Spring Boot 4, Java 21, in Docker |
| Database | PostgreSQL 16 in Docker (Testcontainers for integration tests) |
| Browser | Chromium (Playwright), Chrome (Selenium), headless in CI |
| Node.js | 20 LTS or newer |
| CI | GitHub Actions, ubuntu-latest |
| Local | `docker compose up -d --build`, app on http://localhost:8080 |

## 6. Test data

- Each test creates its own data through the API or a factory class, with a unique title (for example `Task-<timestamp>`)
- Each test deletes what it created, so tests can run in any order
- Boundary values come from the validation table in `development-plan.md`
- No shared or production-like personal data

## 7. Entry and exit criteria

**Entry criteria (testing of a step starts when)**

- The feature branch builds and unit tests pass
- The app starts in Docker and `/actuator/health` returns UP
- Test cases for the feature are written in this plan

**Exit criteria (the MVP is ready when)**

- 100% of High priority test cases pass
- At least 95% of all automated tests pass, with the failures logged as known issues
- No open Critical or Major defects
- Service layer coverage of at least 80%
- Every requirement R1 to R7 has passing tests
- The Allure report is published

## 8. Defect management

Defects are logged as GitHub Issues with the bug template (title, steps, expected, actual, environment, severity, evidence).

| Severity | Meaning | Example |
| --- | --- | --- |
| Critical | Core function broken, no workaround | App does not start; tasks cannot be created |
| Major | Function broken, workaround exists | Filter returns wrong tasks |
| Minor | Small functional or display problem | Wrong date format on the page |
| Trivial | Cosmetic | Typo in an error message |

Lifecycle: **Open → In progress → Fixed → Verified (retest passes) → Closed**, or **Rejected** with a reason. Every fixed bug gets a regression test.

## 9. Risks and mitigation

| Risk | Mitigation |
| --- | --- |
| Flaky UI tests | `data-testid` locators, auto-waits and explicit waits, test data created via API, 1 retry in CI only |
| Tests depend on each other's data | Unique data per test and cleanup after each test |
| Differences between local and CI | Same Docker setup everywhere |
| Limited time | Small MVP scope, High priority cases first |
| New tools (Playwright, TypeScript) | Learning time planned in Week 5 |

## 10. Schedule and deliverables

| Week | Testing activity | Deliverable |
| --- | --- | --- |
| 1 | Draft this plan, CI pipeline | Test plan v0.1, green CI |
| 2 | Unit and validation tests | Unit test suite |
| 3 | Integration tests | Integration suite with Testcontainers |
| 4 | API tests, Cucumber, SQL checks | API suite, Allure report in CI |
| 5 | UI tests, exploratory sessions | Playwright and Selenium suites, charter notes |
| 6 | Regression run, bug reports, summary | Test summary report, published Allure report, test plan v1.0 |

**Test summary report** (end of Week 6, in `docs/test-summary.md`): number of tests per level, pass rate, coverage, defects found by severity, open issues, and lessons learned.
