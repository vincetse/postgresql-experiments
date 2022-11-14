-- train model with the data in the select statement
CREATE MODEL demo_ml.customer_churn_model
FROM (SELECT state,
             area_code,
             total_charge/account_length AS average_daily_spend,
             cust_serv_calls/account_length AS average_daily_cases,
             churn
      FROM demo_ml.customer_activity
         WHERE record_date < '2020-01-01'
     )
TARGET churn
FUNCTION predict_customer_churn
IAM_ROLE 'arn:aws:iam::168992916458:role/RedshiftML'
SETTINGS (
  S3_BUCKET 'redshiftml-168992916458'
)
;

SHOW MODEL demo_ml.customer_churn_model;
