CREATE TABLE IF NOT EXISTS
    reports (
        id SERIAL PRIMARY KEY,
        reporter_id VARCHAR(255) NOT NULL,
        reported_id VARCHAR(255) NOT NULL,
        TIMESTAMP TIMESTAMPTZ DEFAULT NOW()
    );