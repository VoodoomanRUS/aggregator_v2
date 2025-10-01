-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS loan_applications
(
    UUID           VARCHAR(36) UNIQUE PRIMARY KEY,
    UserId         VARCHAR(36) NOT NULL REFERENCES users(UUID),
    OrganizationID VARCHAR(36) NOT NULL REFERENCES organizations(UUID),
    Status         bool DEFAULT FALSE,
    Created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    Updated_at     TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_loan_applications_uuid ON loan_applications (UUID);
CREATE INDEX IF NOT EXISTS idx_loan_applications_userid ON loan_applications (UserId);
CREATE INDEX IF NOT EXISTS idx_loan_applications_organizationid ON loan_applications (OrganizationID);
CREATE INDEX IF NOT EXISTS idx_loan_applications_status ON loan_applications (Status);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- CORE MIGRATION DO NOT DROP
DROP INDEX IF EXISTS idx_loan_applications_uuid;
DROP INDEX IF EXISTS idx_loan_applications_userid;
DROP INDEX IF EXISTS idx_loan_applications_organizationid;
DROP INDEX IF EXISTS idx_loan_applications_status;
DROP TABLE IF EXISTS loan_applications;
-- +goose StatementEnd

