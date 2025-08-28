USE bank_db;

-- What attributes are more common among churners than non-churners? 
SELECT exited, 
	   AVG(creditscore) AS avg_credit_score,
       AVG(age) AS avg_age,
       AVG(tenure) AS avg_tenure,
       ROUND(AVG(balance),2) AS avg_balance,
       ROUND(AVG(estimated_salary),2) AS avg_estimated_salary
FROM bank_churn
GROUP BY exited;

/*
Churners are older on average (44.8 vs 37.4) and keep a much higher balance (91k vs 28k) 
despite the nearly same stimated salary (~100k both).
Credit score is slightly lower among churners (645 vs 652).
Tenure is not very different (≈5 years both).
*/

SELECT gender, exited,
       COUNT(*) AS num_customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY gender), 2) AS pct_within_gender
FROM bank_churn
GROUP BY gender, exited
ORDER BY gender, exited;

/*
Even though more men are in the dataset overall (5457 vs 4543 women), 
the proportion of churners is higher for women.
*/

SELECT exited, geography, COUNT(geography) AS num_customers,
	   ROUND((COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY geography)) * 100.0, 2) AS pct_within_geo
FROM bank_churn
GROUP BY exited, geography
ORDER BY geography;

/*
German customers churn much more often than customers in France or Spain (32% vs 16% for both).
*/

-- Can churn be predicted using the variables in the data?


SELECT * FROM bank_churn;

-- What do the overall demographics of the bank's customers look like?

-- Is there a difference between German, French, and Spanish customers in terms of account behavior?

-- What types of segments exist within the bank's customers?
