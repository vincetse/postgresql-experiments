-- Clean up before starting
DROP TABLE IF EXISTS numbers CASCADE;

-- Create a parent table
CREATE TABLE numbers (
    id BIGINT
)
;

-- Create a bunch of child tables
CREATE UNLOGGED TABLE numbers_p01 (
) INHERITS (numbers)
;

CREATE UNLOGGED TABLE numbers_p02 (
) INHERITS (numbers)
;

CREATE TABLE numbers_p03 (
) INHERITS (numbers)
;

-- Insert directly into child tables
INSERT INTO numbers_p01
SELECT GENERATE_SERIES(1, 10000000)::BIGINT AS id
;

INSERT INTO numbers_p02
SELECT GENERATE_SERIES(10000001, 20000000)::BIGINT AS id
;

INSERT INTO numbers_p03
SELECT GENERATE_SERIES(20000001, 30000000)::BIGINT AS id
;

-- Create indices for child tables
CREATE INDEX ON numbers_p01(id);

CREATE INDEX ON numbers_p02(id);

CREATE INDEX ON numbers_p03(id);

-- Now make sure we see the correct number of records from parent table
SELECT
    COUNT(*)
FROM
    numbers
;

-- Clear up after we're done
DROP TABLE IF EXISTS numbers CASCADE;
