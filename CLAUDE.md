# To-Do App: Portfolio Project

## What this project is

A small Java to-do app, fully covered by automated tests at every level.
It is a portfolio project for job applications in the Netherlands
(QA / Test Automation Engineer, SDET, Junior Software Engineer).

The app is simple on purpose. The value is in clean code and good tests.
I must be able to explain every line in an interview.

Detailed plans are in `docs/`:
- `docs/build-plan.md`: goals, scope, tech stack, roadmap
- `docs/development-plan.md`: epics E0 to E8 (tasks, subtasks, Definition of Done),
  data model, API contract
- `docs/test-plan.md`: requirements R1 to R7, test cases TC-01 to TC-33

Always follow `docs/development-plan.md` epic by epic, task by task.
Epics are also tracked as GitHub Issues (label `epic`).

## MVP scope

- Create, view, edit, delete a task
- Fields: title (required, max 100), description (optional, max 500),
  status (TODO / DONE, default TODO), due date (optional), created date
- Filter by status
- Validation with clear error messages
- One web page (Thymeleaf) with the task list

Not in the MVP (do not add unless I ask): login, priority, sorting,
search, tags, pagination.

## Tech stack

- Java 21, Maven (multi-module from E2), Spring Boot 4
  (Web, Data JPA / Hibernate, Validation, Actuator), Thymeleaf + Bootstrap
- PostgreSQL 16 + Flyway, Docker + docker-compose
- springdoc OpenAPI (Swagger UI)
- Unit: JUnit 5, Mockito, AssertJ
- Integration: Spring Boot Test, Testcontainers, MockMvc
- API: REST Assured, Cucumber, JSON schema validation, SQL checks, Allure
- UI: Playwright with TypeScript (main), Selenium WebDriver 4 in Java (3 or 4 tests)
- Coverage: JaCoCo. CI: GitHub Actions. Reports: Allure on GitHub Pages

## Project structure

```
todo-app/
  app/              Spring Boot app + unit and integration tests
  api-tests/        REST Assured + Cucumber + Allure (Java)
  ui-tests/         Playwright + TypeScript (pages/, tests/)
  selenium-tests/   a few Selenium tests (Java)
  perf-tests/       optional
  docs/             plans, test strategy, exploratory notes
  .github/workflows/ci.yml
  docker-compose.yml
  pom.xml           parent POM
```

## Commands

```bash
docker compose up -d                  # start PostgreSQL (and the app from E2)
cd app && ./mvnw spring-boot:run      # run the app locally
./mvnw -B verify                      # build + unit + integration tests
./mvnw -pl api-tests test             # API tests (app must be running)
cd ui-tests && npx playwright test    # Playwright UI tests
```

Health check: http://localhost:8080/actuator/health
Swagger UI: http://localhost:8080/swagger-ui.html

## Code rules

- Base package: `com.portfolio.todo`
- Layers: controller, service, repository, model, dto, exception
- DTOs are Java records. No business logic in controllers
- All API errors use one JSON shape: status, error, message, fieldErrors
- Keep code simple and readable. Prefer clear names over clever code
- No new libraries without asking me first

## Test rules

- Test names describe behavior: `shouldReturn404WhenTaskDoesNotExist`
- Tests are independent: each test creates its own data and cleans it up
- Use unique test data (for example `Task-<timestamp>`)
- UI locators use `data-testid` only
- Never use `Thread.sleep`. Use Playwright auto-waits or `WebDriverWait`
- Link tests to test case IDs from `docs/test-plan.md` where possible
- Every bug fix gets a regression test

## Git rules

- One branch per epic: `feature/e<n>-<short-name>`; the PR closes the epic issue (`Closes #<n>`)
- Conventional Commits: `feat:`, `test:`, `ci:`, `docs:`, `fix:`
- Small commits. CI must be green before merging

## How to work with me

- Work on one epic at a time. Do not jump ahead to later epics
- Every epic ends logically: a complete feature I can demonstrate, with its tests
- For every task, first tell me the goal, why we need it, the test cases (TC IDs),
  the subtasks and "done when". Then let me try to work out the code myself:
  give hints first, and full code only if I ask or get stuck
- One small subtask at a time. Always show where we are in the epic
- I write the application and test code myself. You review it
- Before writing code, show a short plan and wait for my OK
- After changes, explain what you did and why in simple English,
  like to a junior engineer. I am learning
- If something is unclear or there are several good options, ask me
- Never commit secrets or passwords
- Do not run `git push` or merge without asking me
