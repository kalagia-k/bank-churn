DROP SCHEMA IF EXISTS bank_db;
CREATE SCHEMA bank_db;
USE bank_db;

--
-- Table structure for table `bank_churn`
--

CREATE TABLE bank_churn(
customerid INT NOT NULL,
surname VARCHAR(50) NOT NULL,
creditscore SMALLINT NOT NULL,
geography VARCHAR(50) NOT NULL,
gender VARCHAR(10) NOT NULL,
age TINYINT NOT NULL,
tenure TINYINT NOT NULL,
balance DECIMAL(15,2) NOT NULL,
num_of_products	TINYINT NOT NULL,
has_cr_card	BOOLEAN NOT NULL,
is_active_member BOOLEAN NOT NULL,
estimated_salary DECIMAL(15,2) NOT NULL,
exited BOOLEAN NOT NULL,
PRIMARY KEY (customerid)
);

--
-- Load data into table bank_churn
--

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/path/to/Bank_Churn.csv'
INTO TABLE bank_churn
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES 
(customerid, surname, creditscore, geography, gender, age, tenure, balance,
 num_of_products, has_cr_card, is_active_member, estimated_salary, exited);
 
 --
 -- Quick check that everything is correct
 --
 
SELECT COUNT(*) AS rows_loaded FROM bank_churn;

SELECT * FROM bank_churn 
WHERE customerid IN (15634602, 15647311, 15619304, 15701354, 15737888);
