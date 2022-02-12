-- MAVEN ANALYTICS NYC TAXI CHALLENGE by  Evelyn Wangai

-- 1. CREATED A NEW TABLE WITH 2017-2020 TAXI TRIPS
-- DROPPED congestion_surchages columns in 2019 and 2020 tables, so that I can use a UNION ALL 

---- CLEANING THE DATA
USE [NYCTaxiProject]
DROP TABLE IF EXISTS [dbo].[taxi_trips]
GO

--Drop congestion_surchages columns in 2019 and 2020 tables, so that I can use a UNION ALL to join 2017 - 2020 tables into 1 table
ALTER TABLE [dbo].[2019_taxi_trips] DROP COLUMN [congestion_surcharge]
GO

ALTER TABLE [dbo].[2020_taxi_trips] DROP COLUMN [congestion_surcharge]
GO

--1. Let’s stick to trips that were NOT sent via “store and forward”
-- 2. I’m only interested in street-hailed trips paid by card or cash, with a standard rate
-- 3. We can remove any trips with dates before 2017 or after 2020, along with any trips with pickups or drop-offs into unknown zones
SELECT *
INTO taxi_trips
FROM (
		SELECT * 
		FROM [dbo].[2017_taxi_trips]
		UNION ALL
		SELECT * 
		FROM [dbo].[2018_taxi_trips]
		UNION ALL
		SELECT * 
		FROM [dbo].[2019_taxi_trips]
		UNION ALL
		SELECT * 
		FROM [dbo].[2020_taxi_trips] ) n

WHERE store_and_fwd_flag = '"N"'
AND RatecodeID = 1
AND payment_type < 3
AND lpep_pickup_datetime BETWEEN '2017-01-01' AND '2020-12-30'

-- change the datatype of some columns that were initially varchar
ALTER TABLE  [dbo].[taxi_trips] ALTER COLUMN [trip_distance] FLOAT
ALTER TABLE  [dbo].[taxi_trips] ALTER COLUMN [fare_amount] FLOAT
ALTER TABLE  [dbo].[taxi_trips] ALTER COLUMN [mta_tax] FLOAT
ALTER TABLE  [dbo].[taxi_trips] ALTER COLUMN [improvement_surcharge] FLOAT
ALTER TABLE  [dbo].[taxi_trips] ALTER COLUMN [total_amount] FLOAT

-- 4. Let’s assume any trips with no recorded passengers had 1 passenger
UPDATE[dbo].[taxi_trips]
SET passenger_count = 1
where passenger_count = 0

-- 5. If a pickup date/time is AFTER the drop-off date/time, let’s swap them
UPDATE [dbo].[taxi_trips]
set lpep_pickup_datetime = CASE
						WHEN lpep_dropoff_datetime < lpep_pickup_datetime THEN lpep_dropoff_datetime
						ELSE lpep_pickup_datetime
						end

-- 6. We can remove trips lasting longer than a day, and any trips which show both a distance and fare amount of 0
DELETE FROM [dbo].[taxi_trips]
WHERE  DATEDIFF(HOUR,lpep_pickup_datetime, lpep_dropoff_datetime) > 24

DELETE FROM [dbo].[taxi_trips]
WHERE  trip_distance = 0 and fare_amount = 0

-- 6. If you notice any records where the fare, taxes, and surcharges are ALL negative, please make them positive
UPDATE [dbo].[taxi_trips]
SET fare_amount = ABS(fare_amount)
where fare_amount < 0

UPDATE [dbo].[taxi_trips]
SET mta_tax = ABS(mta_tax)
where mta_tax < 0

UPDATE [dbo].[taxi_trips]
SET improvement_surcharge = ABS(improvement_surcharge)
where improvement_surcharge < 0

-- 7. For any trips that have a fare amount but have a trip distance of 0, calculate the distance this way: (Fare amount - 2.5) / 2.5
UPDATE [dbo].[taxi_trips]
SET trip_distance = (fare_amount - 2.5 )/ 2.5
WHERE trip_distance = 0 and fare_amount != 0

-- 8. For any trips that have a trip distance but have a fare amount of 0, calculate the fare amount this way: 2.5 + (trip distance x 2.5)
UPDATE [dbo].[taxi_trips]
set [fare_amount] = 2.5 + (trip_distance * 2.5)
where fare_amount = 0 and trip_distance != 0 


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- To join taxi_trips table with taxi_zones; I will create another table to join on pickup location AND ZONES

USE [NYCTaxiProject]
DROP TABLE IF EXISTS [dbo].[taxi_trips]
GO

select *
into taxi_clean
from (
		select *
		from [dbo].[taxi_trips]
		inner join [dbo].[taxi_zones]
		ON [dbo].[taxi_trips].PULocationID = [dbo].[taxi_zones].LocationID )x

alter table [dbo].[taxi_clean] drop column locationID
------------ Create another table to join on Drop off location ID 

select *
into taxi_clean2
from (
		select *
		from [dbo].[taxi_clean]
		inner join [dbo].[taxi_zones]
		ON [dbo].[taxi_clean].DOLocationID = [dbo].[taxi_zones].LocationID) y

delete from [dbo].[taxi_clean2]
where PO_Borough = 'Unknown'
and DO_Borough = 'Unknown'

SELECT * FROM [dbo].[taxi_clean2]
