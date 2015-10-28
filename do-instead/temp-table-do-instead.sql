\timing
-- Clean up before starting
DROP TABLE IF EXISTS numbers CASCADE;

-- Create a parent table
CREATE UNLOGGED TABLE numbers (
    id BIGINT
)
;

-- Now create the temp table that we will put the do-instead rule on
CREATE TEMP TABLE foo AS
SELECT * FROM numbers WHERE false;

-- Create the rule
CREATE OR REPLACE RULE foo_to_numbers AS
    ON INSERT TO foo
    DO INSTEAD
        INSERT INTO numbers(id)
        VALUES (NEW.id)
;

-- Now insert some records to foo
INSERT INTO foo
SELECT GENERATE_SERIES(1, 10000000)::BIGINT AS id
;

-- Where are the records
SELECT COUNT(*) FROM foo;
SELECT COUNT(*) FROM numbers;

-- DROP RULE foo_to_numbers;
