BEGIN TRANSACTION;
CREATE TABLE clubs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(60) NOT NULL UNIQUE,
    website VARCHAR(512),
    contact VARCHAR(256),
    description VARCHAR(1024),
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    member_fee VARCHAR(64),
    member_count INTEGER DEFAULT 0,
    registration VARCHAR(20) DEFAULT 'open',
    audience VARCHAR(100)
);
COMMIT;
