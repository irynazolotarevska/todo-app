# Development Plan

The exact build order for the MVP in 10 steps. Each step is one branch and one pull request, ends with green CI, and maps to a week of the roadmap.

## Conventions

- One branch per step: `feature/<step-name>`, merged into `main` by pull request only when CI is green
- Commit messages: `feat:`, `test:`, `ci:`, `docs:`, `fix:` (Conventional Commits)
- Base package: `com.portfolio.todo`
- Done for every step: code + tests, CI green, PR merged, README updated if something changed

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

| Method | Path | Body | Success | Errors |
| --- | --- | --- | --- | --- |
| GET | /api/tasks?status=TODO | none | 200 + list | 400 for unknown status |
| GET | /api/tasks/{id} | none | 200 + task | 404 |
| POST | /api/tasks | title, description, dueDate | 201 + Location header + task | 400 |
| PUT | /api/tasks/{id} | title, description, status, dueDate | 200 + task | 400, 404 |
| DELETE | /api/tasks/{id} | none | 204 | 404 |

Every error returns the same JSON shape, so tests can check it with one schema:

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "fieldErrors": [ { "field": "title", "message": "must not be blank" } ]
}
```

## Step 1: Project skeleton and CI (Week 1)

Branch `feature/setup`

- [ ] Generate the project on start.spring.io: Maven, Java 21, Spring Boot 4, group `com.portfolio`, artifact `todo-app`
- [ ] Dependencies: Spring Web, Spring Data JPA, Validation, PostgreSQL Driver, Flyway, Thymeleaf, Actuator
- [ ] Put it in `app/` (the parent POM comes in Step 7)
- [ ] `docker-compose.yml` with a `postgres:16` service, database `todo`, port 5432, a named volume
- [ ] `application.yml`: datasource URL, user, password from environment variables with local defaults
- [ ] `.github/workflows/ci.yml`: checkout, setup-java 21 (Temurin, Maven cache), `./mvnw -B verify`

```bash
docker compose up -d
cd app && ./mvnw spring-boot:run
curl http://localhost:8080/actuator/health   # {"status":"UP"}
```

**Done when:** health endpoint says UP and the first CI run is green.

## Step 2: Task model and database (Week 1)

Branch `feature/task-model`

- [ ] Flyway migration `V1__create_tasks.sql` (above)
- [ ] `TaskStatus` enum (TODO, DONE) and `Task` JPA entity
- [ ] `TaskRepository extends JpaRepository<Task, Long>` with `List<Task> findByStatus(TaskStatus status)`
- [ ] DTOs as Java records: `CreateTaskRequest`, `UpdateTaskRequest`, `TaskResponse`, plus a small `TaskMapper`
- [ ] Validation annotations on the requests: `@NotBlank`, `@Size(max = 100)`, `@Size(max = 500)`

**Done when:** app starts and Flyway creates the table (check with `docker exec` and `\dt`).

## Step 3: Service and unit tests (Week 2)

Branch `feature/task-service`

- [ ] `TaskService`: `findAll(status)`, `findById(id)`, `create(request)`, `update(id, request)`, `delete(id)`
- [ ] `TaskNotFoundException` thrown for unknown ids
- [ ] New tasks always start as TODO; `createdAt` set by the service
- [ ] `TaskServiceTest` with Mockito and AssertJ, for example:
  - `shouldCreateTaskWithStatusTodo`
  - `shouldReturnOnlyDoneTasksWhenFilteredByDone`
  - `shouldThrowNotFoundWhenUpdatingMissingTask`
  - `shouldThrowNotFoundWhenDeletingMissingTask`
  - `shouldUpdateAllFieldsOfExistingTask`
- [ ] `TaskRequestValidationTest`: `@ParameterizedTest` with the boundary values from the validation table, using a Jakarta `Validator`

**Done when:** service coverage is above 80% and all tests run in CI.

## Step 4: REST controller and error handling (Week 2)

Branch `feature/task-api`

- [ ] `TaskController` on `/api/tasks` with `@Valid` request bodies; POST returns `ResponseEntity.created(location)`
- [ ] `GlobalExceptionHandler` (`@RestControllerAdvice`): validation errors to 400, `TaskNotFoundException` to 404, unreadable JSON or wrong enum to 400, all in the error shape above
- [ ] Add `springdoc-openapi-starter-webmvc-ui`; Swagger UI at `/swagger-ui.html`
- [ ] Try every endpoint by hand in Swagger and save the requests as a Postman collection in `docs/postman/`

**Done when:** every row of the API contract works in Swagger.

## Step 5: Integration tests (Week 3)

Branch `feature/integration-tests`

- [ ] Dependencies: `spring-boot-testcontainers`, Testcontainers `postgresql` and `junit-jupiter`
- [ ] `TaskRepositoryIT`: `@DataJpaTest` with a real PostgreSQL container (`@ServiceConnection`)
- [ ] `TaskControllerIT`: `@SpringBootTest` + `@AutoConfigureMockMvc`, checks status codes, Location header and error bodies
- [ ] Maven Failsafe plugin so `*IT` classes run in `mvn verify`

**Done when:** integration tests run in CI with Docker (GitHub runners have it by default).

## Step 6: Web page (Week 3)

Branch `feature/web-ui`

- [ ] `TaskPageController` (`@Controller`) on `/`, template `templates/tasks.html` with Bootstrap from a CDN
- [ ] Form actions: `POST /tasks`, `POST /tasks/{id}/edit`, `POST /tasks/{id}/done`, `POST /tasks/{id}/delete`, filter with `?status=`
- [ ] Validation errors shown under the form
- [ ] `data-testid` on every element tests will touch:

| Element | data-testid |
| --- | --- |
| Form, inputs, button | task-form, task-title-input, task-description-input, task-due-input, task-submit |
| One task row | task-row, task-title, task-status, task-due |
| Row buttons | task-done-btn, task-edit-btn, task-delete-btn |
| Filter and errors | status-filter, error-message, empty-state |

**Done when:** you can do every MVP action in the browser.

## Step 7: API test framework (Week 4)

Branch `feature/api-tests`

- [ ] Parent `pom.xml` at the root with modules `app`, `api-tests`, `selenium-tests`
- [ ] `Dockerfile` for the app (multi-stage: Maven build, then a JRE image) and an `app` service in `docker-compose.yml`
- [ ] `api-tests` dependencies: REST Assured, JUnit 5, AssertJ, json-schema-validator, Cucumber (java + junit-platform-engine), Allure (junit5 + rest-assured), PostgreSQL driver for SQL checks
- [ ] Packages: `config` (base URL from `-DbaseUrl`, default `http://localhost:8080`), `client/TaskClient`, `model`, `data/TaskFactory`, `db/DbHelper`, `tests`, `steps`
- [ ] Clean up: every test deletes the tasks it created (`@AfterEach`)
- [ ] Test cases:
  - create valid task: 201, body matches `task-schema.json`, row exists in the database
  - title blank, only spaces, 101 chars: 400 with the right `fieldErrors`
  - title exactly 100 chars: 201
  - get, update, delete unknown id: 404 with error schema
  - update: 200 and the new values are in the database (SQL check)
  - delete: 204, then GET returns 404
  - filter by DONE returns only DONE tasks
  - invalid status value: 400
- [ ] `features/tasks.feature` with 3 to 5 Gherkin scenarios (create, complete, delete) and their step definitions
- [ ] New CI job: `docker compose up -d --build`, wait for `/actuator/health`, `./mvnw -pl api-tests test`, upload `allure-results`

**Done when:** the API suite runs in CI against the app in Docker.

## Optional step: Live deployment (after Step 7, decision pending)

Branch `feature/deploy`. Puts the app online so recruiters can click a live link. It needs the `Dockerfile` from Step 7; the hosting choice is still open and will be made when this step starts.

| Option | Setup effort | Database | Cost | Best for |
| --- | --- | --- | --- | --- |
| Render | Low: connect GitHub, builds from the Dockerfile | Managed PostgreSQL | Free tier (app sleeps when idle) | Fastest live link |
| Azure App Service | Medium: Azure account, container or Java app, Azure Database for PostgreSQL | Managed PostgreSQL | Free tier and starter credits | NL CV keyword (Azure is common in Dutch ads) |
| Both, Render first | Low now, medium later | Both | Free tiers | Quick link now, Azure as a bonus |
| Alternatives | Railway (low), Fly.io (medium), VPS such as Hetzner (high) | Varies | Free tier to about €5/month | More control |

Free tiers change often: check current limits before choosing.

**Steps (same for any platform)**

- [ ] Choose the platform from the table above
- [ ] Create the managed PostgreSQL database
- [ ] Set environment variables: database URL, user, password (never commit them)
- [ ] Deploy from GitHub using the Dockerfile; turn on auto-deploy from `main`
- [ ] Check `/actuator/health` on the live URL
- [ ] Run the API smoke tests against the live URL (`-DbaseUrl=https://...`)
- [ ] Add the live link and a "Live demo" badge to the README

**Done when:** the live link works and the smoke tests pass against it.

## Step 8: Playwright TypeScript UI tests (Week 5)

Branch `feature/ui-tests`

```bash
cd ui-tests
npm init playwright@latest   # TypeScript, tests folder, skip the GitHub Actions file
npm i -D allure-playwright
npx playwright test --ui     # handy while writing tests
```

- [ ] `playwright.config.ts`: `baseURL` from `process.env.BASE_URL`, Chromium only, `screenshot: 'only-on-failure'`, `trace: 'retain-on-failure'`, reporters `list` and `allure-playwright`
- [ ] `pages/TaskPage.ts`: locators with `getByTestId`, methods `addTask`, `editTask`, `markDone`, `deleteTask`, `filterBy`
- [ ] `fixtures.ts`: a `taskPage` fixture plus test data created through the API (`request` fixture), so UI tests only test the UI
- [ ] Tests (8 to 10): add task, add with empty title shows error, edit title, mark done, filter by status, delete, empty state, task with due date shows it
- [ ] CI job: setup-node, `npm ci`, `npx playwright install --with-deps chromium`, `npx playwright test`

**Done when:** UI tests pass headless in CI and failures attach screenshots and traces.

## Step 9: Selenium Java tests (Week 5)

Branch `feature/selenium-tests`

- [ ] Module `selenium-tests` with `selenium-java` 4 (Selenium Manager downloads the driver, no extra library needed)
- [ ] `TaskPage.java` Page Object, `WebDriverWait` explicit waits only, headless Chrome
- [ ] 3 or 4 tests: add task, mark done, delete task
- [ ] Runs in the same CI job as the API tests (app already up)

**Done when:** Selenium tests pass in CI.

## Step 10: Reports, docs and release (Week 6)

Branch `feature/polish`

- [ ] JaCoCo in the `app` module and a coverage badge
- [ ] Combine all `allure-results`, generate the report and publish it to GitHub Pages
- [ ] `docs/test-plan.md` and `docs/test-strategy.md` final versions
- [ ] Bug report template in `.github/ISSUE_TEMPLATE/bug.md` (title, steps, expected, actual, environment, severity, evidence) and 3 to 5 real issues
- [ ] README: description, screenshot, badges, how to run, how to run each suite, link to the Allure report
- [ ] Tag release `v1.0.0`

**Done when:** the final checklist in `build-plan.md` is complete.

## CI pipeline

| Job | Runs | Needs |
| --- | --- | --- |
| build | `./mvnw -B verify -pl app` (unit + integration tests, JaCoCo) | none |
| api-and-selenium | app in Docker, API tests, Cucumber, Selenium | build |
| ui-playwright | app in Docker, Playwright tests | build |
| report | merge Allure results, publish to GitHub Pages (main branch only) | all jobs, runs even if tests fail |
