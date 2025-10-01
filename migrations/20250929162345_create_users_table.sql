-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS users(
    UUID VARCHAR(36) unique primary key,
    Name VARCHAR(64),
    Email VARCHAR(255) UNIQUE,
    Created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    Updated_at TIMESTAMP,
    Deleted_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_users_uuid ON users (UUID);
CREATE INDEX IF NOT EXISTS idx_users_email ON users (Email);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- CORE MIGRATION DO NOT DROP
DROP INDEX IF EXISTS idx_users_uuid;
DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;
-- +goose StatementEnd
