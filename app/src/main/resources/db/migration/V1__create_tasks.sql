CREATE TABLE tasks (
                       id          BIGSERIAL PRIMARY KEY,
                       title       VARCHAR(100) NOT NULL,
                       description VARCHAR(500),
                       status      VARCHAR(10)  NOT NULL DEFAULT 'TODO',
                       due_date    DATE,
                       created_at  TIMESTAMP    NOT NULL DEFAULT now()
);