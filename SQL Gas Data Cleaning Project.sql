-- Data Cleaning Project- Gas Data

-- First let's select the correct schema to use

USE energy_consumption_report;

-- Let's rename the table to something more relevant

ALTER TABLE `Energy_Consumption_Report`.`gas_data_sql_project` 
RENAME TO  `Energy_Consumption_Report`.`gas_data_2024` ;

-- Refresh the Schema to check the table name updated correctly

-- Now let's check the table data imported correctly

SELECT * 
FROM gas_data_2024;

-- Let's create a copy of the table that we can clean with so that we keep the raw data as it was for best practise

CREATE TABLE gas_data_2024_clean
LIKE gas_data_2024;

-- I will check to see if the columns were created correctly

SELECT * 
FROM gas_data_2024_clean;

-- Now we will insert the original data into the cleaning copy

INSERT gas_data_2024_clean
SELECT * 
FROM gas_data_2024;

-- Now let's check the table data imported correctly

SELECT * 
FROM gas_data_2024_clean;

-- Let begin the cleaning process in the following order
-- 1. Remove Any Duplicates
-- 2. Standarise the Data
-- 3. Deal with any Null Values or Blanks
-- 4. Remove any unnecessary columns

-- 1. Remove Any Duplicates
-- To check for duplicates I will use row numbers to find help duplicate values

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY `Date`, `Value`, Unit) AS row_num 
FROM gas_data_2024_clean;

-- Using a CTE I will locate the specific duplicates

WITH duplicate_cte_gas AS (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY `Date`, `Value`, Unit) AS row_num 
FROM gas_data_2024_clean)
SELECT * FROM duplicate_cte_gas WHERE row_num > 1;

-- We have now identified 14 duplicate values

-- Lets delete these duplicate values by creating another table to store the CTE values since we need to delete values where row_num > 1 since this column is in the CTE only and not the table

-- Create new table

CREATE TABLE `gas_data_2024_clean2` (
  `Date` text,
  `Value` double DEFAULT NULL,
  `Unit` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert the values from the CTE created previously

INSERT INTO gas_data_2024_clean2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY `Date`, `Value`, Unit) AS row_num 
FROM gas_data_2024_clean;

-- Check the table to see if the data inserted correctly

SELECT * 
FROM gas_data_2024_clean2;

-- Now let's delete the duplicates

DELETE FROM gas_data_2024_clean2
WHERE row_num > 1;

-- Lets check that they are gone

SELECT * 
FROM gas_data_2024_clean2
WHERE row_num > 1;

-- Now duplicates are removed, it's time to move on next stage of data cleaning which is...
-- 2. Standardise the Data
-- Date column was a string, so we need to change to DATE format

UPDATE gas_data_2024_clean2
SET Date = str_to_date(Date, '%d/%m/%Y')
WHERE str_to_date(Date, '%d/%m/%Y') is not null;

-- Then alter the table to that it changes to DATETIME and refresh the table to see if the column has changed from text to DATETIME

ALTER TABLE gas_data_2024_clean2
MODIFY COLUMN `Date` DATE;

-- Now the data has been standaised, let's move on next stage of data cleaning which is...
-- 3. Deal with any Null Values or Blanks
-- Let's check if we have any NULLs or blank values

SELECT *
FROM gas_data_2024_clean2
WHERE `Date` IS NULL;

-- There are no nulls in the date columns, let's check the value column

SELECT *
FROM gas_data_2024_clean2
WHERE `Value` IS NULL;

-- And there is no NULL values
-- Let's check blank values

SELECT *
FROM gas_data_2024_clean2
WHERE `Value` = ' ';

-- There are also no blank values

-- Now the data has been checked for NULLs and Blanks, let's move on next stage of data cleaning which is...
-- 4. Remove any unnecessary columns

-- Let's check our table again to see if any columns are irrelevant for data analysis

SELECT *
FROM gas_data_2024_clean2;

-- There are 2 irrelevant columns, the Unit column and the row_num column now that we have already got rid of the duplicate value from earlier, so let's remove them

ALTER TABLE gas_data_2024_clean2
DROP COLUMN UNIT;

ALTER TABLE gas_data_2024_clean2
DROP COLUMN row_num;


-- Now let's check the table one last time

SELECT *
FROM gas_data_2024_clean2;

-- Columns have now been dropped

-- All the data has now been cleaned
