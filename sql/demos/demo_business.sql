CREATE TABLE business_contract (
    contract_version VARCHAR(20) PRIMARY KEY,
    business_timezone VARCHAR(50) NOT NULL,
    allowed_currency VARCHAR(3) NOT NULL,
    amount_unit VARCHAR(20) NOT NULL,
    date_tolerance_days INTEGER NOT NULL,
    amount_tolerance_cents INTEGER NOT NULL
);

INSERT INTO business_contract VALUES (
    '1.0.0',
    'America/Bogota',
    'USD',
    'cents',
    2,
    5
);

SELECT
    business_timezone,
    allowed_currency,
    amount_unit,
    date_tolerance_days,
    amount_tolerance_cents
FROM business_contract
WHERE contract_version = '1.0.0';