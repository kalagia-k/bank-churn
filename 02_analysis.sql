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

WITH churn_pred AS
(
SELECT *,
	   CASE
			WHEN geography = 'Germany' and gender = 'Female' 
            AND balance > 91000 AND age > 44
            THEN 'Likely_Churn'
		ELSE 'Likely_NotChurn'
END AS churn_prediction
FROM bank_churn
),
pred_result AS
(
SELECT exited, churn_prediction,
	   CASE 
			WHEN exited = 0 AND churn_prediction = 'Likely_NotChurn' THEN 'correct'
            WHEN exited = 1 AND churn_prediction = 'Likely_Churn' THEN 'correct'
		ELSE 'not_correct'
END AS prediction_result
FROM churn_pred
)
SELECT prediction_result, COUNT(*) AS totals,
	   ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pred_result), 2) AS percentage
FROM pred_result
GROUP BY prediction_result;


/*
The simple rule I tested reached ~81% accuracy. 
This shows that churn is related to attributes like geography, gender, balance, and age, 
but we would need more advanced models to make reliable predictions.
*/


-- What do the overall demographics of the bank's customers look like?

WITH age_groups AS(
SELECT *,
	   CASE
			WHEN age < 30 THEN '<30'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50+'
       END AS age_group
FROM bank_churn)
SELECT geography, age_group, COUNT(*) AS total_customers,
	   ROUND(100.0 * (COUNT(*) / (SELECT COUNT(*) FROM bank_churn)), 2) AS pct_of_bank
FROM age_groups
GROUP BY geography, age_group
ORDER BY pct_of_bank DESC;

/*
France dominates the customer base, especially ages 30–39 (22.5% of all customers).
Spain and Germany also have strong 30–39 segments (≈11% and 10%).
Customers under 30 and 50+ make up smaller proportions in every geography (typically <9%).
Overall, the bank’s customers are mostly 30–49 years old, with France contributing the largest share.
*/

WITH age_groups AS(
SELECT *,
	   CASE
			WHEN age < 30 THEN '<30'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50+'
       END AS age_group
FROM bank_churn)
SELECT geography, age_group,
       COUNT(*) AS total_customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY geography), 2) AS pct_within_geo
FROM age_groups
GROUP BY geography, age_group
ORDER BY pct_within_geo DESC;

/*
In all three countries, the 30–39 age group dominates (≈40–45% of customers).
The 40–49 group is the next largest (≈25–30%).
Customers under 30 make up ~15–17% in each geography.
The 50+ group is the smallest everywhere (~13–16%).
*/


-- Is there a difference between German, French, and Spanish customers in terms of account behavior?

SELECT geography, ROUND(AVG(balance), 2) AS avg_balance, 
	   ROUND(AVG(creditscore), 1) AS avg_creditscore, AVG(tenure) AS avg_tenure, 
       ROUND(AVG(estimated_salary), 1) AS avg_est_salary,
	   ROUND(100.0 * AVG(has_cr_card), 2) AS pct_with_creditcard,
       ROUND(100.0 * AVG(is_active_member), 2) AS pct_active_members,
       ROUND(AVG(num_of_products), 2) AS avg_num_products
FROM bank_churn
GROUP BY geography;

/*
German customers hold almost double the average balance compared to French and Spanish customers (~120k vs ~62k).
The remaining attributes (credit score, tenure, estimated salary, product ownership, and credit card usage) are similar across all three countries.
French and Spanish customers look the most similar in their account behavior.
*/

-- What types of segments exist within the bank's customers?


SELECT geography, gender, age_group, COUNT(*) AS total_customers
FROM (
  SELECT *,
         CASE WHEN age < 30 THEN '<30'
              WHEN age BETWEEN 30 AND 39 THEN '30-39'
              WHEN age BETWEEN 40 AND 49 THEN '40-49'
              ELSE '50+'
         END AS age_group
  FROM bank_churn
) t
GROUP BY geography, gender, age_group
ORDER BY total_customers DESC
LIMIT 5;


SELECT 
  CASE WHEN balance = 0 THEN 'No Balance'
       WHEN balance < 50000 THEN '<50k'
       WHEN balance < 100000 THEN '50k-100k'
       ELSE '100k+'
  END AS balance_segment,
  num_of_products,
  is_active_member,
  COUNT(*) AS customers
FROM bank_churn
GROUP BY balance_segment, num_of_products, is_active_member
ORDER BY customers DESC
LIMIT 5;

/*
The bank’s customers can be segmented by demographics and by account behavior. 
Demographically, the largest group is French males in their 30s, followed by French women in their 30s. 
Behaviorally, two major groups stand out: high-balance customers with just one product (both active and inactive), and no-balance customers with multiple products.
*/