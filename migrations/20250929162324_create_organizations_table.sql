-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS organizations(
    UUID VARCHAR(36) UNIQUE,
    Name VARCHAR(64) UNIQUE,
    Email VARCHAR(255) UNIQUE,
    Created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    Updated_at TIMESTAMP,
    Deleted_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_organizations_uuid ON organizations (UUID);
CREATE INDEX IF NOT EXISTS idx_organizations_name ON organizations (Name);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_organizations_uuid;
DROP INDEX IF EXISTS idx_organizations_name;
DROP TABLE IF EXISTS organizations;
-- +goose StatementEnd
