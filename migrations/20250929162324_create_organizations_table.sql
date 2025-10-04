-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS organizations(
    uuid VARCHAR(36) UNIQUE,
    name VARCHAR(64) UNIQUE,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_organizations_uuid ON organizations (uuid);
CREATE INDEX IF NOT EXISTS idx_organizations_name ON organizations (name);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_organizations_uuid;
DROP INDEX IF EXISTS idx_organizations_name;
DROP TABLE IF EXISTS organizations;
-- +goose StatementEnd
