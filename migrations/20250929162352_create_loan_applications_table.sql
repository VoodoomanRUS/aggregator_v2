-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS loan_applications
(
    uuid                       VARCHAR(36) UNIQUE PRIMARY KEY,
    value                      DECIMAL(18, 2) NOT NULL
        CONSTRAINT chk_positive_value CHECK ( value >= 1000 ),
    incoming_organization_uuid VARCHAR(36) REFERENCES organizations(uuid),
    issue_organization_uuid    VARCHAR(36) REFERENCES organizations(uuid),
    created_at                 TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at                 TIMESTAMP,
    deleted_at                 TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_loan_applications_uuid ON loan_applications(uuid);
CREATE INDEX IF NOT EXISTS idx_loan_applications_incoming_organization_uuid ON loan_applications(incoming_organization_uuid);
CREATE INDEX IF NOT EXISTS idx_loan_applications_issue_organization_uuid ON loan_applications(issue_organization_uuid);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- CORE MIGRATION DO NOT DROP
DROP INDEX IF EXISTS idx_loan_applications_uuid;
DROP INDEX IF EXISTS idx_loan_applications_incoming_organization_uuid;
DROP INDEX IF EXISTS idx_loan_applications_issue_organization_uuid;
DROP TABLE IF EXISTS loan_applications;
-- +goose StatementEnd

