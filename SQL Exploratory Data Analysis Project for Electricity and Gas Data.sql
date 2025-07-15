-- Exploratory Data Analysis

-- Add new columns
ALTER TABLE electricity_data_2024_clean2
ADD COLUMN DayOfWeek VARCHAR(20),
ADD COLUMN WeekNumber VARCHAR(20),
ADD COLUMN MonthOfYear VARCHAR(20);

-- Populate the new columns using date functions
UPDATE electricity_data_2024_clean2
SET DayOfWeek = DAYNAME(Date), WeekNumber = Week(Date, 3), MonthOfYear = MONTHNAME(Date);

-- Add new columns
ALTER TABLE gas_data_2024_clean2
ADD COLUMN DayOfWeek VARCHAR(20),
ADD COLUMN WeekNumber VARCHAR(20),
ADD COLUMN MonthOfYear VARCHAR(20);

-- Split Date column into Date and Time column

ALTER TABLE electricity_data_2024_clean2
ADD COLUMN DateOnly DATE,
ADD COLUMN TimeOnly TIME;

UPDATE electricity_data_2024_clean2
SET 
DateOnly = DATE(Date),
TimeOnly = TIME(Date);


-- Populate the new columns using date functions
UPDATE gas_data_2024_clean2
SET DayOfWeek = DAYNAME(Date), WeekNumber = Week(Date, 3), MonthOfYear = MONTHNAME(Date);


-- lets join the tables together to visually compare side by side, I must use a subquery as electricity has multiple values per day. 
-- I have only selected the relevant columns and rounded values to 1 decimal places.

SELECT g.`Date`, round(g.`Value`, 1) as GasConsumption, round(e.ElecConsumption, 1) as ElecConsumption, DayOfWeek
FROM (SELECT DateOnly, sum(`Value`) as ElecConsumption FROM electricity_data_2024_clean2 Group by DateOnly) as e
JOIN gas_data_2024_clean2 as g
ON e.DateOnly = g.`Date`
ORDER BY `Date`;

-- Lets see the highest consumtion for electricity by month

SELECT round(sum(`value`), 1) AS Consumption, MonthOfYear
FROM electricity_data_2024_clean2
GROUP BY MonthOfYear
ORDER BY Consumption desc;

-- January, March and Feb are the highest consumers. let's limit by these top 3
SELECT round(sum(`value`), 1) AS Consumption, MonthOfYear
FROM electricity_data_2024_clean2
GROUP BY MonthOfYear
ORDER BY Consumption DESC
LIMIT 3;

-- Lets do the same for the 3 lowest consumers
SELECT round(sum(`value`), 1) AS Consumption, MonthOfYear
FROM electricity_data_2024_clean2
GROUP BY MonthOfYear
ORDER BY Consumption ASC
LIMIT 3;

-- December, then August then September are the 3 lowest consumers

-- Lets do the same for Gas
SELECT round(sum(`value`), 1) AS Consumption, MonthOfYear
FROM gas_data_2024_clean2
GROUP BY MonthOfYear
ORDER BY Consumption DESC
LIMIT 3;

-- January, December, and Feb are the highest consumers.

SELECT round(sum(`value`), 1) AS Consumption, MonthOfYear
FROM gas_data_2024_clean2
GROUP BY MonthOfYear
ORDER BY Consumption ASC
LIMIT 3;

-- July, August and June are the lowest

-- Lets see what the highest consuming days are for electrcity
SELECT round(sum(`value`), 1) AS Consumption, DayOfWeek
FROM electricity_data_2024_clean2
GROUP BY DayOfWeek
ORDER BY Consumption DESC;

-- Tuesday, Wednesday and Thursday are the highest consumers as expected due to people mainly working from home Monday and Friday, and no one working the weekend

-- Lets check gas
SELECT round(sum(`value`), 1) AS Consumption, DayOfWeek
FROM gas_data_2024_clean2
GROUP BY DayOfWeek
ORDER BY Consumption DESC;

-- Suprisingly, Gas doesn't follow the same trend, this will likely mean there is something that needs investigating for the site as gas is being wasted!

-- What are the 5 highest consuming days of the year for electricity? ***
SELECT round(sum(`value`), 1) AS Consumption, `DateOnly`
FROM electricity_data_2024_clean2
GROUP BY `DateOnly`
ORDER BY Consumption DESC
LIMIT 5;

-- 18th, 10th, 19th, 15th, 9th January have the highest consumption. Something Major must have been happening onsite during those couple of weeks!
-- How about gas?
SELECT round(sum(`value`), 1) AS Consumption, `Date`
FROM gas_data_2024_clean2
GROUP BY `Date`
ORDER BY Consumption DESC
LIMIT 5;

-- 1st, 13th, 14, 16th and 20th January had the highest consumption. Since January had the highest consumption, it makes sense that the top 5 days were that month!

-- Let's check the busiest 5 period of the day for electricity on average. We don't have time periods for Gas so we only need to check electricity

SELECT round(avg(`value`), 1) AS Consumption, `TimeOnly`
FROM Electricity_data_2024_clean2
GROUP BY `TimeOnly`
ORDER BY Consumption DESC
LIMIT 5;

-- 9am, 9:30am, 10am, 8:30am and 10:30am were the highest as the office usually has most people starting during these times, everyone needs to make a hot drink and plug their equipment in before starting work!

-- What about the quietest times? ****
SELECT round(avg(`value`), 1) AS Consumption, `TimeOnly`
FROM Electricity_data_2024_clean2
GROUP BY `TimeOnly`
ORDER BY Consumption ASC
LIMIT 5;

-- Not suprisingly 23:30, 23:00, 22:30, 22:00 and 21:30 has the lowest consumption as the building is closed at these times. 

-- What is the maximum electricity consumption throughout the year? This is important as peak consumption charges can occur if thresholds are breached! Let's check minimum and average too!
SELECT round(MAX(`Value`)) AS Peak_Consumption, round(MIN(`Value`)) as Minimum_Consumption, round(AVG(`Value`)) AS Average_Consumption
From Electricity_data_2024_clean2;

-- Maximum Electricity Consumption was 189kWh, Minimum was 62kWh and Average was 90kWh
-- Since average and minimum Electricity Consumption included when the site was closed, let's see during business hours and weekdays only. it is unlikely Max consumption occured outside of these hours but let's check anyway!

SELECT round(MAX(`Value`)) AS Peak_Consumption, round(MIN(`Value`)) as Minimum_Consumption, round(AVG(`Value`)) AS Average_Consumption
From Electricity_data_2024_clean2
WHERE TimeOnly BETWEEN '08:00:00' AND '17:00:00' and DayOfWeek NOT IN('Saturday','Sunday');

-- Peak Electricity Consumption, as suspected, is still 189kWh, however Minimum Consumption is now 69kWh and Average Consumption is 123kWh
