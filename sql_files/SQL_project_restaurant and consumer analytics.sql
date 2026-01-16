create database restaurantconsumeranalytics;

create table consumers(Consumer_ID varchar(10) primary key, City varchar(255), 
State varchar(255), Country varchar(255), Latitude Decimal(10,7), 
Longitude Decimal(10, 7), Smoker varchar(10), Drink_Level varchar(50), 
Transportation_Method varchar(50), Marital_Status varchar(20), Children varchar(20), 
Age int, Occupation varchar(50), Budget varchar(10));   

create table restaurants(Restaurant_ID int primary key, Name varchar(255), City varchar(255), 
State varchar(255), Country varchar(255), Zip_Code varchar(10), Latitude Decimal(10,8), 
Longitude Decimal(11, 8), Alcohol_Service varchar(50), Smoking_Allowed varchar(50), 
Price varchar(10), Franchise varchar(5), Area varchar(10), Parking varchar(50));

create table ratings(Consumer_ID varchar(10), Restaurant_ID int, Overall_Rating int, 
Food_Rating int, Service_Rating int, PRIMARY KEY (Consumer_ID, Restaurant_ID),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)); 
    
    
create table restaurent_cuisine(Restaurant_ID int, Cuisine varchar(255), PRIMARY KEY (Restaurant_ID, Cuisine),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)); 
    
    
CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(255),
    PRIMARY KEY (Consumer_ID, Preferred_Cuisine),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID)
);

select * from consumers;
select * from restaurants;
select * from ratings; 
select * from restaurent_cuisine; 
select * from consumer_preferences; 

-- List all details of consumers who live in the city of 'Cuernavaca'.
select * from consumers where City = 'Cuernavaca';

-- 1.Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select Consumer_ID, Age, Occupation from consumers where Occupation = 'Student' and Smoker = 'Yes'; 

-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
select Name, City, Alcohol_Service, Price from restaurants where Alcohol_Service = 'Wine & Beer'
 and Price = 'Medium'; 

 -- 2. Find the names and cities of all restaurants that are part of a 'Franchise'.
 select Name, City from restaurants where Franchise = 'Yes'; 
 
-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings 
-- where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, 
-- according to the data dictionary). 
select Consumer_ID, Restaurant_ID, Overall_Rating from ratings where Overall_Rating = 2; 

-- 3.List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
select r.Name, r.City from restaurants r join ratings ra on r.restaurant_ID = ra.Restaurant_ID
where ra.Overall_Rating = 2;

-- Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
 select c.Consumer_ID, c.Age from consumers c join ratings ra on c.Consumer_ID = ra.Consumer_ID 
 join restaurants r on ra.Restaurant_ID = r.Restaurant_ID where r.City = 'San Luis Potosi';

-- List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select r.Name as Restaurant_Name from restaurants r join restaurent_cuisine rc 
on r.Restaurant_ID = rc.Restaurant_ID join ratings ra on r.Restaurant_ID = ra.Restaurant_ID 
where rc.Cuisine = 'Mexican' and ra.Consumer_ID = 'U1001'; 

-- Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
select * from consumer_preferences;

-- 4.List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
select r.Name, r.City from restaurants r join ratings ra on r.Restaurant_ID = ra.Restaurant_ID
where ra.Food_Rating < (select avg(Food_Rating) from ratings); 

-- Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
SELECT DISTINCT c.Consumer_ID, c.Age, c.Occupation
FROM consumers c
JOIN ratings ra ON c.Consumer_ID = ra.Consumer_ID
WHERE c.Consumer_ID NOT IN (
    SELECT DISTINCT ra2.Consumer_ID
    FROM ratings ra2
    JOIN restaurent_cuisine rc2 
        ON ra2.Restaurant_ID = rc2.Restaurant_ID
    WHERE rc2.Cuisine = 'Italian'
); 

-- 5.List restaurants (Name) that have received ratings from consumers older than 30.
select r.Name from restaurants r join ratings ra on r.Restaurant_ID = ra.Restaurant_ID 
join consumers c on ra.Consumer_ID = c.Consumer_ID where c.Age > 30; 

-- Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
UPDATE consumer_preferences
SET Preferred_Cuisine = REPLACE(Preferred_Cuisine, CHAR(13), ''); 

select distinct c.Consumer_ID, c.Occupation from consumers c join consumer_preferences cp 
on c.Consumer_ID = cp.Consumer_ID join ratings ra on cp.Consumer_ID = ra.Consumer_ID where 
cp.Preferred_Cuisine = 'Mexican' and ra.Overall_Rating = 0;   

-- 6.List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
UPDATE restaurent_cuisine
SET Cuisine = REPLACE(Cuisine, CHAR(13), ''); 

select r.Name, r.City from restaurants r join restaurent_cuisine rc on r.Restaurant_ID = rc.Restaurant_ID
where rc.Cuisine = 'Pizzeria' and r.City in (select City from consumers where 
Occupation = 'Student');

-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
-- select c.Consumer_ID, c.Age from consumers c join ratings ra on c.Consumer_ID = ra.Consumer_ID 
-- join restaurants r on ra.Restaurant_ID = r.Restaurant_ID 
-- where c.Drink_Level = 'Social Drinker' and r.Parking = 'None'; 
-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
select c.Consumer_ID, c.Age from consumers c join ratings ra on c.Consumer_ID = ra.Consumer_ID 
join restaurants r on ra.Restaurant_ID = r.Restaurant_ID 
where c.Drink_Level = 'Social Drinker' and r.Parking not in ("Public", "Yes"); 

-- List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
select c.Consumer_ID, count(*) as Restaurant_Count 
from consumers c join ratings ra on c.Consumer_ID = ra.Consumer_ID 
where c.Occupation = 'Student' 
group by c.Consumer_ID having count(*) > 2; 

-- We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation.
select Consumer_ID, Age, (Age / 10) as Engagement_Score 
from consumers where (Age / 10) = 2
and Transportation_Method = 'Public';

-- For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.
select r.Name, r.City, avg(ra.Overall_Rating) as Avg_Overall_Rating 
from restaurants r 
join ratings ra on r.Restaurant_ID = ra.Restaurant_ID 
where r.City = 'Cuernavaca' group by 
r.restaurant_ID having avg(ra.Overall_Rating) > 1.0; 

-- Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.
select c.Consumer_ID, c.Age from consumers c 
join ratings ra on c.Consumer_ID = ra.Consumer_ID 
where c.Marital_Status = 'Married' 
and ra.Overall_Rating = 2 and ra.Food_Rating = ra.Service_Rating;

-- Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.
WITH SanLuisConsumers AS (
    SELECT Consumer_ID, Age
    FROM consumers
    WHERE City = 'San Luis Potosi'
)
SELECT DISTINCT s.Consumer_ID, s.Age, r.Name AS Restaurant_Name
FROM SanLuisConsumers s
JOIN ratings ra ON s.Consumer_ID = ra.Consumer_ID
JOIN restaurants r ON ra.Restaurant_ID = r.Restaurant_ID
JOIN restaurent_cuisine rc ON r.Restaurant_ID = rc.Restaurant_ID
WHERE LOWER(TRIM(rc.Cuisine)) = 'mexican'
  AND ra.Overall_Rating = 2;
  
-- For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. (Use a derived table to get consumers who have rated).
SELECT c.Occupation, AVG(c.Age) AS Avg_Age
FROM consumers c
JOIN (
    SELECT DISTINCT Consumer_ID
    FROM ratings
) rated_consumers
    ON c.Consumer_ID = rated_consumers.Consumer_ID
GROUP BY c.Occupation;

-- Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.
WITH CuernavacaRatings AS (
    SELECT 
        ra.Restaurant_ID,
        ra.Consumer_ID,
        ra.Overall_Rating
    FROM ratings ra
    JOIN restaurants r 
        ON ra.Restaurant_ID = r.Restaurant_ID
    WHERE r.City = 'Cuernavaca'
)
SELECT 
    Restaurant_ID,
    Consumer_ID,
    Overall_Rating,
    RANK() OVER (PARTITION BY Restaurant_ID ORDER BY Overall_Rating DESC) AS RatingRank
FROM CuernavacaRatings
ORDER BY Restaurant_ID, RatingRank; 

-- For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.
SELECT 
    ra.Consumer_ID,
    ra.Restaurant_ID,
    ra.Overall_Rating,
    AVG(ra.Overall_Rating) 
        OVER (PARTITION BY ra.Consumer_ID) AS Avg_Rating_By_Consumer
FROM ratings ra
ORDER BY ra.Consumer_ID, ra.Restaurant_ID; 

-- Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).
WITH LowBudgetStudents AS (
    SELECT Consumer_ID
    FROM consumers
    WHERE LOWER(TRIM(Occupation)) = 'student'
      AND LOWER(TRIM(Budget)) = 'low'
),
RankedCuisines AS (
    SELECT 
        cp.Consumer_ID,
        cp.Preferred_Cuisine,
        ROW_NUMBER() OVER (
            PARTITION BY cp.Consumer_ID 
            ORDER BY cp.Consumer_ID, cp.Preferred_Cuisine
        ) AS PreferenceRank
    FROM consumer_preferences cp
    JOIN LowBudgetStudents lbs
        ON cp.Consumer_ID = lbs.Consumer_ID
)
SELECT 
    Consumer_ID,
    Preferred_Cuisine,
    PreferenceRank
FROM RankedCuisines
WHERE PreferenceRank <= 3
ORDER BY Consumer_ID, PreferenceRank;
 
-- Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first.
SELECT 
    Restaurant_ID,
    Overall_Rating,
    LEAD(Overall_Rating) OVER (ORDER BY Restaurant_ID) AS Next_Restaurant_Rating
FROM (
    SELECT Restaurant_ID, Overall_Rating
    FROM ratings
    WHERE Consumer_ID = 'U1008'
) AS ConsumerRatings
ORDER BY Restaurant_ID; 

-- Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT 
    r.Restaurant_ID,
    r.Name,
    r.City
FROM restaurants r
JOIN restaurent_cuisine rc 
    ON r.Restaurant_ID = rc.Restaurant_ID
JOIN ratings ra 
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE LOWER(TRIM(rc.Cuisine)) = 'mexican'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(ra.Overall_Rating) > 1.5; 

-- First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.
WITH MexicanLovers AS (
    SELECT DISTINCT Consumer_ID
    FROM consumer_preferences
    WHERE LOWER(TRIM(Preferred_Cuisine)) = 'mexican'
)
SELECT ml.Consumer_ID
FROM MexicanLovers ml
WHERE ml.Consumer_ID NOT IN (
    SELECT DISTINCT ra.Consumer_ID
    FROM ratings ra
    JOIN HighlyRatedMexicanRestaurants hmr
        ON ra.Restaurant_ID = hmr.Restaurant_ID
); 

-- Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.
DELIMITER $$

CREATE PROCEDURE GetRestaurantRatingsAboveThreshold (
    IN p_restaurant_id VARCHAR(10),
    IN p_min_rating DECIMAL(3,1)
)
BEGIN
    SELECT 
        Consumer_ID,
        Overall_Rating,
        Food_Rating,
        Service_Rating
    FROM ratings
    WHERE Restaurant_ID = p_restaurant_id
      AND Overall_Rating >= p_min_rating
    ORDER BY Overall_Rating DESC;
END $$

DELIMITER ;

CALL GetRestaurantRatingsAboveThreshold('132572', 2); 

-- First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.
CREATE OR REPLACE VIEW ConsumerAverageRatings AS
SELECT 
    Consumer_ID,
    AVG(Overall_Rating) AS AvgOverallRating
FROM ratings
GROUP BY Consumer_ID; 

WITH TopConsumers AS (
    SELECT 
        Consumer_ID,
        AvgOverallRating
    FROM ConsumerAverageRatings
    ORDER BY AvgOverallRating DESC
    LIMIT 5
)
SELECT 
    tc.Consumer_ID,
    tc.AvgOverallRating,
    COUNT(DISTINCT ra.Restaurant_ID) AS MexicanRestaurantsRated
FROM TopConsumers tc
JOIN ratings ra 
    ON tc.Consumer_ID = ra.Consumer_ID
JOIN restaurent_cuisine rc 
    ON ra.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY tc.Consumer_ID, tc.AvgOverallRating
ORDER BY tc.AvgOverallRating DESC; 

-- Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.
-- The procedure should:
-- Determine the consumer's "Spending Segment" based on their Budget:
     -- 'Low' -> 'Budget Conscious'
	-- 'Medium' -> 'Moderate Spender'
	-- 'High' -> 'Premium Spender'
	-- NULL or other -> 'Unknown Budget' 
    
DROP PROCEDURE IF EXISTS GetConsumerSegmentAndRestaurantPerformance;
DELIMITER $$

CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(IN p_Consumer_ID VARCHAR(10))
BEGIN
    DECLARE v_Budget VARCHAR(20);
    DECLARE v_Segment VARCHAR(30);

    -- Get the consumer's budget
    SELECT Budget 
    INTO v_Budget
    FROM consumers
    WHERE Consumer_ID = p_Consumer_ID;

    -- Determine spending segment
    SET v_Segment = CASE
        WHEN v_Budget = 'Low' THEN 'Budget Conscious'
        WHEN v_Budget = 'Medium' THEN 'Moderate Spender'
        WHEN v_Budget = 'High' THEN 'Premium Spender'
        ELSE 'Unknown Budget'
        END;

    -- Return consumer details with average rating info
    SELECT 
        c.Consumer_ID,
        c.Age,
        c.Occupation,
        c.Budget,
        v_Segment AS Spending_Segment,
        ROUND(AVG(r.Overall_Rating), 2) AS Avg_Overall_Rating,
        COUNT(r.Restaurant_ID) AS Total_Ratings
    FROM consumers c
    LEFT JOIN ratings r 
        ON c.Consumer_ID = r.Consumer_ID
    WHERE c.Consumer_ID = p_Consumer_ID
    GROUP BY c.Consumer_ID, c.Age, c.Occupation, c.Budget, v_Segment;
END $$
DELIMITER ;

CALL GetConsumerSegmentAndRestaurantPerformance('U1001');

-- For all restaurants rated by this consumer:
-- List the Restaurant_Name.
-- The Overall_Rating given by this consumer.
-- The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
-- A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
-- Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).

DROP PROCEDURE IF EXISTS GetConsumerSegmentAndRestaurantPerformance;
DELIMITER $$

CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(IN p_Consumer_ID VARCHAR(10))
BEGIN
    DECLARE v_Budget VARCHAR(20);
    DECLARE v_Segment VARCHAR(30);

    -- Step 1: Get consumer budget
    SELECT Budget 
    INTO v_Budget
    FROM consumers
    WHERE Consumer_ID = p_Consumer_ID;

    -- Step 2: Determine Spending Segment
    SET v_Segment = CASE
        WHEN v_Budget = 'Low' THEN 'Budget Conscious'
        WHEN v_Budget = 'Medium' THEN 'Moderate Spender'
        WHEN v_Budget = 'High' THEN 'Premium Spender'
        ELSE 'Unknown Budget'
    END;

    -- Step 3: Display consumer information and average rating summary
    SELECT 
        c.Consumer_ID,
        c.Age,
        c.Occupation,
        c.Budget,
        v_Segment AS Spending_Segment,
        ROUND(AVG(r.Overall_Rating), 2) AS Avg_Overall_Rating,
        COUNT(r.Restaurant_ID) AS Total_Ratings
    FROM consumers c
    LEFT JOIN ratings r 
        ON c.Consumer_ID = r.Consumer_ID
    WHERE c.Consumer_ID = p_Consumer_ID
    GROUP BY c.Consumer_ID, c.Age, c.Occupation, c.Budget, v_Segment;

    -- Step 4: Compare this consumer’s restaurant ratings with overall restaurant averages
    SELECT 
        rts.Name AS Restaurant_Name,
        ra.Overall_Rating AS Consumer_Rating,
        ROUND(AVG(allr.Overall_Rating), 2) AS Avg_Restaurant_Rating,
        CASE
            WHEN ra.Overall_Rating > AVG(allr.Overall_Rating) THEN 'Above Average'
            WHEN ra.Overall_Rating = AVG(allr.Overall_Rating) THEN 'At Average'
            ELSE 'Below Average'
        END AS Performance_Flag,
        RANK() OVER (PARTITION BY ra.Consumer_ID ORDER BY ra.Overall_Rating DESC) AS Rating_Rank
    FROM ratings ra
    JOIN restaurants rts 
        ON ra.Restaurant_ID = rts.Restaurant_ID
    JOIN ratings allr 
        ON allr.Restaurant_ID = ra.Restaurant_ID
    WHERE ra.Consumer_ID = p_Consumer_ID
    GROUP BY ra.Consumer_ID, ra.Restaurant_ID, ra.Overall_Rating, rts.Name
    ORDER BY ra.Overall_Rating DESC;
END $$

DELIMITER ; 

CALL GetConsumerSegmentAndRestaurantPerformance('U1001');

