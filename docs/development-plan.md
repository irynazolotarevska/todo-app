# Development Plan

The build order for the MVP, split into **epics → tasks → subtasks**. Every epic delivers one complete feature that can be demonstrated, with its tests. The app is always working and always tested, and it grows one feature at a time.

## How we work

| Level | Meaning | In Git / GitHub |
| --- | --- | --- |
| **Epic** | One complete user feature with a logical end | One GitHub Issue (label `epic`), one branch, one pull request |
| **Task** | A small slice that works and is tested on its own | A checklist item in the epic issue, 1 to 3 commits |
| **Subtask** | One thing to write | Part of a commit |

**Every task is described with:** Goal (what a user can do afterwards), Why, Test cases (TC IDs from `test-plan.md`), Subtasks, Done when.

**Definition of Done (every epic):**

1. The feature can be demonstrated (Swagger UI, or the browser from E6)
2. Its test cases from `test-plan.md` are automated and pass
3. CI is green
4. This plan's checklist (and the README, if needed) is updated
5. The pull request is merged and closes the epic issue (`Closes #<n>`)

**Feature epic pattern (E3 to E5 repeat it):** service + unit test → endpoint + MockMvc test → error cases → integration test → API tests → demo in Swagger.

## Conventions

- One branch per epic: `feature/e<n>-<short-name>`, merged into `main` by pull request only when CI is green
- Commit messages: `feat:`, `test:`, `ci:`, `docs:`, `fix:` (Conventional Commits)
- Base package: `com.portfolio.todo`

## Data model

One table is enough for the MVP.

```sql
-- app/src/main/resources/db/migration/V1__create_tasks.sql
CREATE TABLE tasks (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    status      VARCHAR(10)  NOT NULL DEFAULT 'TODO',
    due_date    DATE,
    created_at  TIMESTAMP    NOT NULL DEFAULT now()
);
```

**Validation rules** (these become your boundary tests)

| Field | Rule | Boundary test values |
| --- | --- | --- |
| title | required, 1 to 100 characters, not only spaces | "", "   ", 1 char, 100 chars, 101 chars |
| description | optional, max 500 characters | null, 500 chars, 501 chars |
| status | TODO or DONE | TODO, DONE, "done", "OPEN" |
| dueDate | optional, ISO date (yyyy-MM-dd) | null, "2026-12-01", "01-12-2026" |

## API contract

| Method | Path | Body | Success | Errors | Epic |
| --- | --- | --- | --- | --- | --- |
| POST | /api/tasks | title, description, dueDate | 201 + Location header + task | 400 | E1 |
| GET | /api/tasks | none | 200 + list | none | E1 |
| GET | /api/tasks/{id} | none | 200 + task | 404 | E1 |
| PUT | /api/tasks/{id} | title, description, status, dueDate | 200 + task | 400, 404 | E3 |
| DELETE | /api/tasks/{id} | none | 204 | 404 | E4 |
| GET | /api/tasks?status=TODO | none | 200 + list | 400 for unknown status | E5 |

Every error returns the same JSON shape, so tests can check it with one schema:

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "fieldErrors": [ { "field": "title", "message": "must not be blank" } ]
}
```

## Overview

| Epic | Feature | Logical end: "you can now…" | Req |
| --- | --- | --- | --- |
| E0 | Foundation | …start the app; table, entity, repository and DTOs are ready | |
| E1 | Create and view tasks | …create a task and see it; bad input gives 400, unknown id gives 404 | R1, R2, R7 |
| E2 | API test framework | …run black-box API tests for everything that exists, in CI | R1, R2, R7 |
| E3 | Edit and mark done | …change a task and mark it DONE | R3, R4 |
| E4 | Delete | …delete a task: full CRUD works | R5 |
| E5 | Filter by status | …filter tasks: API MVP complete | R6 |
| E6 | Web page + Playwright | …do everything in the browser, with UI tests | R1 to R7 |
| E7 | Selenium | …run a few UI checks with a second tool | R1, R4, R5 |
| E8 | Reports and release | …show a finished `v1.0.0` with published reports | all |

---

## E0: Foundation

Branches `feature/setup`, `feature/task-model`

**Logical end:** the app starts against PostgreSQL, Flyway creates the `tasks` table, and the entity, repository and DTOs are ready to use.

- [x] Project skeleton in `app/` (Spring Boot 4, Java 21, Maven), `docker-compose.yml` with PostgreSQL 16
- [x] `application.yml`: datasource from environment variables, `ddl-auto: validate`, `open-in-view: false`
- [x] CI: `.github/workflows/ci.yml` runs `./mvnw -B verify`
- [x] Flyway migration `V1__create_tasks.sql`
- [x] `TaskStatus` enum, `Task` entity, `TaskRepository` with `findByStatus`
- [x] DTO records `CreateTaskRequest`, `UpdateTaskRequest`, `TaskResponse` with validation
- [ ] CI green, PR merged

## E1: Create and view tasks

Branch `feature/e1-create-view-tasks` · Requirements R1, R2, R7

**Logical end:** in Swagger UI you can create a task, see it in the list and open it by id. Bad input returns a clear 400; an unknown id returns 404.

### 1.1 The service creates a task

- **Goal:** the app can turn a create request into a saved task
- **Why:** business rules (new tasks start as TODO, `createdAt` is set) live in the service, not in the controller
- **Test cases:** TC-01 (unit level)
- [ ] `TaskMapper`: `toEntity(CreateTaskRequest)`, `toResponse(Task)`
- [ ] `TaskService.create(request)`: maps, sets `createdAt`, saves, returns `TaskResponse`
- [ ] `TaskServiceTest` (Mockito + AssertJ): `shouldCreateTaskWithStatusTodo`, `shouldSetCreatedAtWhenCreatingTask`
- **Done when:** unit tests pass

### 1.2 Endpoint: create a task

- **Goal:** a client can create a task over HTTP
- **Why:** the API is the product's front door; the controller only translates HTTP into service calls
- **Test cases:** TC-01 (web layer)
- [ ] `TaskController` on `/api/tasks`: `POST` with `@Valid @RequestBody`, returns `ResponseEntity.created(location)`
- [ ] Add `springdoc-openapi-starter-webmvc-ui`; Swagger UI at `/swagger-ui.html`
- [ ] `TaskControllerTest` (`@WebMvcTest`, service mocked): `shouldReturn201AndLocationWhenTaskIsCreated`
- **Done when:** the test passes and you create a task in Swagger UI

### 1.3 Bad input gives a clear error

- **Goal:** invalid input is rejected with 400 in the standard error shape, and nothing is saved
- **Why:** R7; clients and testers need one predictable error format
- **Test cases:** TC-03 to TC-10
- [ ] `ErrorResponse` and `FieldError` records (status, error, message, fieldErrors)
- [ ] `GlobalExceptionHandler` (`@RestControllerAdvice`): validation errors → 400, unreadable JSON or bad date → 400
- [ ] `TaskRequestValidationTest`: `@ParameterizedTest` with the boundary values above, using a Jakarta `Validator`
- [ ] `TaskControllerTest`: blank title → 400 with `fieldErrors`, malformed JSON → 400
- **Done when:** tests pass and Swagger shows the error shape

### 1.4 View tasks

- **Goal:** a client can see all tasks and open one by id
- **Why:** R2; a created task you cannot see is only half a feature
- **Test cases:** TC-11, TC-12, TC-13
- [ ] `TaskNotFoundException` (in `exception`)
- [ ] `TaskService.findAll()`, `findById(id)`; unit tests incl. `shouldThrowNotFoundWhenTaskDoesNotExist`
- [ ] `GET /api/tasks`, `GET /api/tasks/{id}`; the handler maps `TaskNotFoundException` → 404
- [ ] `TaskControllerTest`: 200 for the list and by id, `shouldReturn404WhenTaskDoesNotExist`
- **Done when:** tests pass; in Swagger you create a task and then see it

### 1.5 Works with the real database

- **Goal:** proof that the whole chain works with a real PostgreSQL
- **Why:** unit tests mock the database; only integration tests catch mapping, SQL and migration problems
- **Test cases:** TC-02, TC-32
- [ ] Dependencies: `spring-boot-testcontainers`, Testcontainers `postgresql` and `junit-jupiter`
- [ ] Maven Failsafe plugin so `*IT` classes run in `mvn verify`
- [ ] `TaskRepositoryIT` (`@DataJpaTest`, `@ServiceConnection`): Flyway creates the table, save and read back
- [ ] `TaskControllerIT` (`@SpringBootTest` + MockMvc): create, then GET returns the same values
- **Done when:** integration tests pass locally and in CI

### 1.6 Demo and close

- [ ] Try every E1 endpoint in Swagger (happy path and errors)
- [ ] Update this checklist; PR with `Closes #<n>`; CI green; merge

## E2: API test framework

Branch `feature/e2-api-tests` · Requirements R1, R2, R7

**Logical end:** a separate black-box test suite checks every existing endpoint against the app running in Docker, automatically in CI, with an Allure report.

### 2.1 Multi-module Maven

- [ ] Parent `pom.xml` at the root with modules `app` and `api-tests`
- **Done when:** `./mvnw -B verify` from the root builds everything and CI is green

### 2.2 App in Docker

- [ ] `Dockerfile` (multi-stage: Maven build, then a JRE image) and an `app` service in `docker-compose.yml`
- **Done when:** after `docker compose up -d --build`, `/actuator/health` returns UP

### 2.3 First API test

- **Test cases:** TC-01
- [ ] Dependencies: REST Assured, JUnit 5, AssertJ
- [ ] Packages: `config` (base URL from `-DbaseUrl`, default `http://localhost:8080`), `client/TaskClient`, `model`
- **Done when:** TC-01 passes against the running app

### 2.4 Test data and database checks

- **Test cases:** TC-02
- [ ] `data/TaskFactory`: unique titles (`Task-<timestamp>`)
- [ ] `db/DbHelper` (PostgreSQL driver): check that a row exists; delete created tasks in `@AfterEach` (there is no DELETE endpoint until E4)
- **Done when:** TC-02 passes and leaves no data behind

### 2.5 Schema validation and the rest of E1's cases

- **Test cases:** TC-03 to TC-13
- [ ] `task-schema.json` and `error-schema.json` with json-schema-validator
- [ ] Negative and boundary tests (`@ParameterizedTest`)
- **Done when:** TC-01 to TC-13 pass

### 2.6 Cucumber

- [ ] `features/tasks.feature`: scenario "Create a task" and its step definitions (more scenarios come in E3 and E4)

### 2.7 Allure and CI

- [ ] Allure (junit5 + rest-assured); tag `@smoke` on TC-01 and TC-11
- [ ] CI job: `docker compose up -d --build`, wait for health, `./mvnw -pl api-tests test`, upload `allure-results`
- **Done when:** the API job is green in CI

## E3: Edit and mark done

Branch `feature/e3-edit-task` · Requirements R3, R4 · Test cases TC-14 to TC-18

**Logical end:** a client can change any field of a task and mark it DONE (and back to TODO).

- [ ] 3.1 `TaskMapper.updateEntity`, `TaskService.update(id, request)`; unit tests `shouldUpdateAllFieldsOfExistingTask`, `shouldThrowNotFoundWhenUpdatingMissingTask`
- [ ] 3.2 `PUT /api/tasks/{id}`; MockMvc tests: 200, 400, 404, invalid status value → 400
- [ ] 3.3 Integration test: update, then GET shows the new values
- [ ] 3.4 API tests TC-14 to TC-18 with SQL checks; Cucumber scenario "Complete a task"
- [ ] 3.5 Demo in Swagger; PR; merge

## E4: Delete a task

Branch `feature/e4-delete-task` · Requirement R5 · Test cases TC-19, TC-20

**Logical end:** full CRUD works.

- [ ] 4.1 `TaskService.delete(id)`; unit tests incl. `shouldThrowNotFoundWhenDeletingMissingTask`
- [ ] 4.2 `DELETE /api/tasks/{id}` → 204; MockMvc tests for 204 and 404
- [ ] 4.3 Integration test: delete, then GET returns 404
- [ ] 4.4 API tests TC-19, TC-20 (`@smoke` on TC-19); Cucumber scenario "Delete a task"; tests may now clean up through the API
- [ ] 4.5 Demo in Swagger; PR; merge

## E5: Filter by status

Branch `feature/e5-filter-tasks` · Requirement R6 · Test cases TC-21 to TC-23, TC-33

**Logical end:** the API MVP is complete; every row of the API contract works.

- [ ] 5.1 `TaskService.findAll(status)` uses `findByStatus` when a status is given; unit test `shouldReturnOnlyDoneTasksWhenFilteredByDone`
- [ ] 5.2 `GET /api/tasks?status=`; an unknown status → 400 in the error shape
- [ ] 5.3 `TaskRepositoryIT`: `findByStatus` returns the right rows (TC-33)
- [ ] 5.4 API tests TC-21 to TC-23
- [ ] 5.5 Demo; service coverage above 80%; PR; merge

## E6: Web page + Playwright

Branch `feature/e6-web-ui` · Requirements R1 to R7 · Test cases TC-24 to TC-31

**Logical end:** every MVP action works in the browser and is covered by a Playwright test.

Each task adds one page feature together with its UI test:

- [ ] 6.1 The page shows the task list and an empty state (`TaskPageController` on `/`, `templates/tasks.html`, Bootstrap from a CDN). Set up Playwright (TypeScript): `playwright.config.ts`, `pages/TaskPage.ts`, `fixtures.ts` with test data created through the API. TC-30
- [ ] 6.2 Add a task with the form; validation errors shown under the form. TC-24, TC-25
- [ ] 6.3 Edit a task and mark it done. TC-26, TC-27
- [ ] 6.4 Delete a task. TC-28
- [ ] 6.5 Filter by status; due date shown in the expected format. TC-29, TC-31
- [ ] 6.6 CI job: setup-node, `npm ci`, `npx playwright install --with-deps chromium`, `npx playwright test`; screenshots and traces on failure

```bash
cd ui-tests
npm init playwright@latest   # TypeScript, tests folder, skip the GitHub Actions file
npm i -D allure-playwright
npx playwright test --ui     # handy while writing tests
```

`data-testid` on every element tests will touch:

| Element | data-testid |
| --- | --- |
| Form, inputs, button | task-form, task-title-input, task-description-input, task-due-input, task-submit |
| One task row | task-row, task-title, task-status, task-due |
| Row buttons | task-done-btn, task-edit-btn, task-delete-btn |
| Filter and errors | status-filter, error-message, empty-state |

## E7: Selenium

Branch `feature/e7-selenium` · Test cases TC-24, TC-27, TC-28

**Logical end:** the main flows are also checked with Selenium WebDriver in Java.

- [ ] 7.1 Module `selenium-tests` with `selenium-java` 4 (Selenium Manager downloads the driver)
- [ ] 7.2 `TaskPage.java` Page Object, `WebDriverWait` explicit waits only, headless Chrome
- [ ] 7.3 Tests: add task, mark done, delete task
- [ ] 7.4 Runs in the same CI job as the API tests

## E8: Reports, docs and release

Branch `feature/e8-release`

**Logical end:** a finished `v1.0.0` that a recruiter can read, run and trust.

- [ ] 8.1 JaCoCo in the `app` module and a coverage badge
- [ ] 8.2 Combine all `allure-results` and publish the report to GitHub Pages
- [ ] 8.3 Exploratory sessions (charters in `test-plan.md`), notes in `docs/exploratory/`
- [ ] 8.4 Bug report template `.github/ISSUE_TEMPLATE/bug.md` and 3 to 5 real issues
- [ ] 8.5 `docs/test-plan.md` v1.0, `docs/test-strategy.md`, `docs/test-summary.md`
- [ ] 8.6 README: description, screenshot, badges, how to run each suite, link to the Allure report
- [ ] 8.7 Tag release `v1.0.0`

## Optional epic: Live deployment (any time after E2, decision pending)

Branch `feature/deploy`. Puts the app online so recruiters can click a live link. It needs the `Dockerfile` from E2; the hosting choice is still open and will be made when this epic starts.

| Option | Setup effort | Database | Cost | Best for |
| --- | --- | --- | --- | --- |
| Render | Low: connect GitHub, builds from the Dockerfile | Managed PostgreSQL | Free tier (app sleeps when idle) | Fastest live link |
| Azure App Service | Medium: Azure account, container or Java app, Azure Database for PostgreSQL | Managed PostgreSQL | Free tier and starter credits | NL CV keyword (Azure is common in Dutch ads) |
| Both, Render first | Low now, medium later | Both | Free tiers | Quick link now, Azure as a bonus |
| Alternatives | Railway (low), Fly.io (medium), VPS such as Hetzner (high) | Varies | Free tier to about €5/month | More control |

Free tiers change often: check current limits before choosing.

- [ ] Choose the platform and create the managed PostgreSQL database
- [ ] Set environment variables: database URL, user, password (never commit them)
- [ ] Deploy from GitHub using the Dockerfile; auto-deploy from `main`
- [ ] Check `/actuator/health`; run the API smoke tests against the live URL (`-DbaseUrl=https://...`)
- [ ] Add the live link and a "Live demo" badge to the README

## CI pipeline (final shape)

| Job | Runs | Needs | Added in |
| --- | --- | --- | --- |
| build | `./mvnw -B verify -pl app` (unit + integration tests, JaCoCo) | none | E0, E1 |
| api-and-selenium | app in Docker, API tests, Cucumber, Selenium | build | E2, E7 |
| ui-playwright | app in Docker, Playwright tests | build | E6 |
| report | merge Allure results, publish to GitHub Pages (main branch only) | all jobs, runs even if tests fail | E8 |
