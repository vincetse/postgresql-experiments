SHOW MODEL demo_ml.customer_churn_model;

-- evaluate performance
CREATE TEMPORARY TABLE infer_data AS
  SELECT area_code ||phone  accountid, churn,
    demo_ml.predict_customer_churn(
          state,
          area_code,
          total_charge/account_length ,
          cust_serv_calls/account_length ) AS predicted
  FROM demo_ml.customer_activity
WHERE record_date <  '2020-01-01'
;

SELECT * FROM infer_data where churn!=predicted;

SELECT
  churn,
  predicted,
  COUNT(*)
FROM
  infer_data
GROUP BY
  1,2
;

-- invoke inference
SELECT area_code ||phone  accountid,
       demo_ml.predict_customer_churn(
          state,
          area_code,
          total_charge/account_length ,
          cust_serv_calls/account_length )
          AS "predictedActive"
FROM demo_ml.customer_activity
WHERE area_code='408' and record_date > '2020-01-01';
