SELECT * FROM t_road_accident;

/*
-- Backup the table
CREATE TABLE `t_road_accident_backup` AS SELECT * FROM `t_road_accident`;
*/

-- Casualties Total
SELECT sum(number_of_casualties) AS Casualties_Total
FROM t_road_accident;

-- Casualties 2022
SELECT sum(number_of_casualties) AS Casualties_2022
FROM t_road_accident
WHERE YEAR(accident_date) = '2022';

-- Casualties 2021
SELECT sum(number_of_casualties) AS Casualties_2021
FROM t_road_accident
WHERE YEAR(accident_date) = '2021';

-- CY Casualties Dry
SELECT sum(number_of_casualties) AS CY_Casualties_Dry
FROM t_road_accident
WHERE YEAR(accident_date) = '2022' 
    AND road_surface_conditions = 'Dry';

-- CY Accidents
SELECT count(DISTINCT accident_index) AS CY_Accidents
FROM t_road_accident 
WHERE  YEAR(accident_date) = '2022'

-- CY Casualties Fatal
SELECT sum(number_of_casualties) AS CY_Casualties_Fatal
FROM t_road_accident
WHERE accident_severity = 'Fatal' 
    AND YEAR (accident_date) = '2022';

-- CY Casualties Serious
SELECT sum(number_of_casualties) AS CY_Casualties_Serious
FROM t_road_accident
WHERE accident_severity = 'Serious' 
    AND YEAR (accident_date) = '2022';

-- CY Casualties Slight
SELECT sum(number_of_casualties) AS CY_Casualties_Slight
FROM t_road_accident
WHERE accident_severity = 'Slight' 
    AND YEAR (accident_date) = '2022';

-- Percentages
SELECT round( sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident),2) AS PCT_Slight 
FROM t_road_accident
WHERE accident_severity = 'Slight';
-- 84.1 %

SELECT ROUND((sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident)), 2) AS PCT_Serious
FROM t_road_accident
WHERE accident_severity = 'Serious';
-- 14.19 %

SELECT ROUND((sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident)), 2) AS PCT_Fatal
FROM t_road_accident
WHERE accident_severity = 'Fatal';
-- 1.71 %

-- CY Percentages
SELECT round(sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident 
    WHERE YEAR(accident_date) = '2022'), 2) AS CY_PCT_Slight
FROM t_road_accident
WHERE accident_severity = 'Slight'
    AND YEAR(accident_date) = '2022';
-- 84.72 %

SELECT round(sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident 
    WHERE YEAR(accident_date) = '2022'), 2) AS CY_PCT_Serious
FROM t_road_accident
WHERE accident_severity = 'Serious'
    AND YEAR(accident_date) = '2022';
-- 13.82 %

SELECT round(sum(number_of_casualties) * 100 / (SELECT sum(number_of_casualties) FROM t_road_accident 
    WHERE YEAR(accident_date) = '2022'), 2) AS CY_PCT_Fatal
FROM t_road_accident
WHERE accident_severity = 'Fatal'
    AND YEAR(accident_date) = '2022';
-- 1.46 %

/*
 * maximum and sum casualties by type of vehicle
 */ 

-- Create Groups
SELECT 
    CASE 
        WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
        WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
        WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Bus'
        WHEN vehicle_type IN ('Van / Goods 3.5 tonnes mgw or under', 'Goods over 3.5t. and under 7.5t', 'Goods 7.5 tonnes mgw and over') THEN 'Van'
        WHEN vehicle_type IN ('Pedal cycle', 'Motorcycle over 500cc', 'Motorcycle over 125cc and up to 500cc', 'Motorcycle 50cc and under', 'Motorcycle 125cc and under') THEN 'Bike'
        ELSE 'Other'
    END AS vehicle_group,
    max (number_of_casualties) AS CY_max_Casualties
--     sum (number_of_casualties) AS CY_Casualties
FROM t_road_accident tra
WHERE YEAR (accident_date) = '2022'
GROUP BY
    CASE 
        WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
        WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
        WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Bus'
        WHEN vehicle_type IN ('Van / Goods 3.5 tonnes mgw or under', 'Goods over 3.5t. and under 7.5t', 'Goods 7.5 tonnes mgw and over') THEN 'Van'
        WHEN vehicle_type IN ('Pedal cycle', 'Motorcycle over 500cc', 'Motorcycle over 125cc and up to 500cc', 'Motorcycle 50cc and under', 'Motorcycle 125cc and under') THEN 'Bike'
        ELSE 'Other'
    END;
    
-- Monthly trend showing comparison of casualties for Current Year and Previous Year 
SELECT 
    monthname(accident_date) AS Month_Name, 
    sum(number_of_casualties) AS CY_Casualties
FROM t_road_accident tra
WHERE YEAR (accident_date) = '2022'
GROUP BY monthname(accident_date); 

SELECT 
    CY.Month_Name,
    PY.PY_Casualties,
    CY.CY_Casualties,
    CY.CY_Casualties - PY.PY_Casualties AS Difference,
    round((CY.CY_Casualties - PY.PY_Casualties) / PY.PY_Casualties * 100, 2) AS 'Diff in %'
FROM 
    (SELECT 
    monthname(accident_date) AS Month_Name, 
    sum(number_of_casualties) AS CY_Casualties
    FROM t_road_accident tra
    WHERE YEAR (accident_date) = '2022'
    GROUP BY monthname(accident_date)) AS CY
JOIN 
    (SELECT 
    monthname(accident_date) AS Month_Name, 
    sum(number_of_casualties) AS PY_Casualties
FROM t_road_accident tra
WHERE YEAR (accident_date) = '2021'
GROUP BY monthname(accident_date)) AS PY
ON CY.Month_Name = PY.Month_Name;

-- Casualties by Road Type for Current Year 
SELECT  
    road_type, 
    sum(number_of_casualties) AS CY_Casualties
FROM t_road_accident
WHERE YEAR (accident_date) = '2022'
GROUP BY road_type
ORDER BY CY_Casualties DESC;

-- Distribution of total casualties by Road Surface 
SELECT 
    road_surface_conditions AS 'Road Surface',
    sum(number_of_casualties) AS Casualties
FROM t_road_accident
GROUP BY road_surface_conditions
ORDER BY Casualties DESC;

-- Relation between Casualties by Area/ Location
SELECT 
    urban_or_rural_area  AS 'Urban/Rural',
    sum(number_of_casualties) AS 'Casualties',
    round(sum(number_of_casualties) * 100 / 
        (SELECT sum(number_of_casualties)
        FROM t_road_accident 
        WHERE YEAR (accident_date) = '2022'), 2) AS 'Casualties in %'
FROM t_road_accident
WHERE YEAR (accident_date) = '2022'
GROUP BY urban_or_rural_area;

SELECT 
    urban_or_rural_area  AS 'Urban/Rural',
    sum(number_of_casualties) AS 'Total Casualties',
    round(sum(number_of_casualties) * 100 / 
        (SELECT sum(number_of_casualties)
        FROM t_road_accident), 2) AS 'Casualties in %'
FROM t_road_accident
GROUP BY urban_or_rural_area;

-- Relation between Casualties by Day / Night
SELECT 
    CASE
        WHEN light_conditions IN ('Daylight') THEN 'Day'
        ELSE 'Dark'
    END AS 'Light Condition',
    sum(number_of_casualties) AS 'CY Casualties',
    round(sum(number_of_casualties) *100 /
        (SELECT sum(number_of_casualties) 
        FROM t_road_accident
        WHERE YEAR (accident_date) = '2022'), 2) AS 'CY Casualties in %'
FROM t_road_accident 
WHERE YEAR (accident_date) = '2022'
GROUP BY 
    CASE
        WHEN light_conditions IN ('Daylight') THEN 'Day'
        ELSE 'Dark'
    END;

-- Top 10 locations by number of Casualties
SELECT 
    local_authority, 
    sum(number_of_casualties) AS  Total_Casualties
FROM t_road_accident
-- WHERE YEAR (accident_date) = '2022'
GROUP BY local_authority 
ORDER  BY Total_Casualties DESC 
LIMIT 10;







