-- https://aws.amazon.com/blogs/big-data/create-train-and-deploy-machine-learning-models-in-amazon-redshift-using-sql-with-amazon-redshift-ml/

DROP USER IF EXISTS demouser;
CREATE USER demouser WITH PASSWORD 'p0sTgres';

GRANT CREATE MODEL TO demouser;

DROP SCHEMA IF EXISTS demo_ml CASCADE;
CREATE SCHEMA demo_ml;

CREATE TABLE demo_ml.customer_activity (
  state VARCHAR(2),
  account_length INT,
  area_code INT,
  phone VARCHAR(8),
  intl_plan VARCHAR(3),
  vMail_plan VARCHAR(3),
  vMail_message INT,
  day_mins FLOAT,
  day_calls INT,
  day_charge FLOAT,
  total_charge FLOAT,
  eve_mins FLOAT,
  eve_calls INT,
  eve_charge FLOAT,
  night_mins FLOAT,
  night_calls INT,
  night_charge FLOAT,
  intl_mins FLOAT,
  intl_calls INT,
  intl_charge FLOAT,
  cust_serv_calls INT,
  churn VARCHAR(6),
  record_DATE date
);

COPY DEMO_ML.customer_activity
FROM 's3://redshift-downloads/redshift-ml/customer_activity/'
IAM_ROLE 'arn:aws:iam::168992916458:role/RedshiftML' delimiter ',' IGNOREHEADER 1
region 'us-east-1';

GRANT SELECT ON demo_ml.customer_activity TO demouser;
GRANT CREATE, USAGE ON SCHEMA demo_ml TO demouser;
