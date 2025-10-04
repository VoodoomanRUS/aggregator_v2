-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS users(
    uuid VARCHAR(36) unique primary key,
    name VARCHAR(64),
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_users_uuid ON users(uuid);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- CORE MIGRATION DO NOT DROP
DROP INDEX IF EXISTS idx_users_uuid;
DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;
-- +goose StatementEnd
