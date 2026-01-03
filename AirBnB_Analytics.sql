-- Creating table for air bnb listings (data imported from csv)
CREATE TABLE bnb_listings (
'ID' INT PRIMARY KEY,
'Name' VARCHAR(400),
'Host_ID' INT,
'Host_Name' VARCHAR(100),
'Neighborhood' INT,
'Latitude' DECIMAL,
'Longitude' DECIMAL,
'Room_Type' VARCHAR (200),
'Price' INT,
'Minimum_Nights' INT,
'Number_of_Reviews' INT,
'Date_of_Last_Review' DATE,
'Reviews_per_Month' DECIMAL,
'Number_of_Host_Listings' INT,
'Days_Available_within_Past_YR' INT,
'Number_of_Reviews_within_LTM' INT) ;


--Creating table for review data (data imported from csv)
CREATE TABLE bnb_reviews (
'Listing_ID' INT,
'Date_of_Review' DATE,
FOREIGN KEY ('Listing_ID') REFERENCES bnb_listings('ID') ) ;


-- Counting number of listings in the data set
SELECT COUNT(ID) as 'Total_Listings'
FROM bnb_listings ;   -- 2876 listings


-- Counting number of unique listings to ensure there are no duplicate listing IDs
SELECT COUNT(DISTINCT ID) as 'Total_Listing_IDs'
FROM bnb_listings bl ;  -- 2876 unique listing IDs (no duplicates)


-- Sorting listings by price and looking at the top 5 most expensive listings
SELECT *
FROM bnb_listings bl 
WHERE bl.Price != ''
ORDER BY bl.Price DESC
LIMIT 5 ;  -- Listing 1339091513653409760 is a bit of an outlier in terms of price ($6846), as it is $4546 more expensive than the second most expensive listing.


-- Sorting listings by price and looking at the 5 least expensive listings
SELECT *
FROM bnb_listings bl 
WHERE bl.Price != ''
ORDER BY bl.Price ASC
LIMIT 5 ;


-- Looking for all listing by host ID 477251437 (host ID that had the most expensive listing)
SELECT *
FROM bnb_listings bl 
WHERE bl.Host_ID = 477251437 ; -- Listing ID 1339091513653409760 is priced significantly higher than their other 7 listings.


-- Calculating average price per night for all listings
SELECT ROUND(AVG(Price), 2) as 'Average_Price_per_Night'
FROM bnb_listings bl ;


-- Calculating median price per night for all listings
SELECT AVG(Price) as Median
FROM (SELECT Price
	  FROM bnb_listings bl
	  WHERE Price != ''
	  ORDER BY Price
	  LIMIT 2
	  OFFSET(SELECT (COUNT(*) - 1) / 2
	  		 FROM bnb_listings bl
	  		 WHERE Price != '')) ;


-- Calculating distribution of the different room types
SELECT Room_Type , COUNT(*) AS 'Number_of_Listings_by_Room_Type'
FROM bnb_listings bl
GROUP BY Room_Type
ORDER BY COUNT(*) DESC ;


-- Calculating number of reviews by room type
SELECT Room_Type , SUM(Number_of_Reviews) AS 'Total_Reviews'
FROM bnb_listings bl
GROUP BY Room_Type 
ORDER BY SUM(Number_of_Reviews) DESC ;


-- Calculating the number of active listings by neighborhood
SELECT Neighborhood , COUNT(*) AS 'Number_of_Listings_by_Neighborhood'
FROM bnb_listings bl 
GROUP BY Neighborhood 
ORDER BY COUNT(*) DESC ;


-- Calculating average listing price per neighborhood
SELECT Neighborhood , ROUND(AVG(Price), 2) AS 'Average_Listing_Price'
FROM bnb_listings bl 
GROUP BY Neighborhood 
ORDER BY AVG(Price) DESC ;


-- Determining the top 5 most expensive neighborhoods
SELECT Neighborhood , ROUND(AVG(Price), 2) AS 'Average_Listing_Price'
FROM bnb_listings bl 
GROUP BY Neighborhood 
ORDER BY AVG(Price) DESC
LIMIT 5 ;


-- Looking for relationship between minimum nights and average listing price
SELECT Minimum_Nights , ROUND(AVG(Price), 2) AS 'Average_Listing_Price'
FROM bnb_listings bl 
GROUP BY Minimum_Nights 
ORDER BY AVG(Price) DESC ;


-- Calculating total number of reviews by neighborhood
SELECT Neighborhood , SUM(Number_of_Reviews) AS 'Total_Reviews'
FROM bnb_listings bl
GROUP BY Neighborhood 
ORDER BY SUM(Number_of_Reviews) DESC ;


-- Calculating average number of reviews per month by neighborhood
SELECT Neighborhood , ROUND(AVG(Reviews_per_Month), 2) AS 'Average_Number_of_Reviews_per_Month'
FROM bnb_listings bl 
GROUP BY Neighborhood  
ORDER BY AVG(Reviews_per_Month) DESC ;


-- Creating view to add columns for month of review, year of review, and season of review (from bnb_reviews table)
CREATE VIEW bnb_reviews_expanded AS
	SELECT *,
	CASE CAST(strftime('%m', Date_of_Review) as integer)
		WHEN 01 THEN 'January'
		WHEN 02 THEN 'February'
		WHEN 03 THEN 'March'
		WHEN 04 THEN 'April'
		WHEN 05 THEN 'May'
		WHEN 06 THEN 'June'
		WHEN 07 THEN 'July'
		WHEN 08 THEN 'August'
		WHEN 09 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
	END AS 'Month_of_Review', STRFTIME('%Y', Date_of_Review) as 'Year_of_Review',
	CASE CAST(strftime('%m', Date_of_Review) as integer)
		WHEN 01 THEN 'Winter'
		WHEN 02 THEN 'Winter'
		WHEN 03 THEN 'Spring'
		WHEN 04 THEN 'Spring'
		WHEN 05 THEN 'Spring'
		WHEN 06 THEN 'Summer'
		WHEN 07 THEN 'Summer'
		WHEN 08 THEN 'Summer'
		WHEN 09 THEN 'Fall'
		WHEN 10 THEN 'Fall'
		WHEN 11 THEN 'Fall'
		WHEN 12 THEN 'Winter'
	END AS 'Season_of_Review'
	FROM bnb_reviews ;


-- Looking for which months had the most activity/reviews
SELECT Month_of_Review , COUNT(Listing_ID) AS 'Number_of_Reviews'
FROM bnb_reviews_expanded bre 
GROUP BY Month_of_Review
ORDER BY COUNT(Listing_ID) DESC ;


-- Looking for which seasons had the most activity/reviews
SELECT Season_of_Review , COUNT(Listing_ID) AS 'Number_of_Reviews'
FROM bnb_reviews_expanded bre 
GROUP BY Season_of_Review 
ORDER BY COUNT(Listing_ID) DESC ;


-- Looking for years that had the most activity/reviews
SELECT Year_of_Review , COUNT(Listing_ID) AS 'Number_of_Reviews'
FROM bnb_reviews_expanded bre 
GROUP BY Year_of_Review
ORDER BY COUNT(Listing_ID) DESC ; 


-- Identifying hosts with the most listings
SELECT DISTINCT Host_ID, Host_Name , Number_of_Host_Listings
FROM bnb_listings bl
ORDER BY Number_of_Host_Listings DESC
LIMIT 5 ;


-- Looking to see if hosts with more listings have a higher average listing price
SELECT DISTINCT Host_ID, Host_Name , Number_of_Host_Listings, ROUND(AVG(Price), 2) as 'Average_Listing_Price'
FROM bnb_listings bl
GROUP BY Host_ID, Host_Name , Number_of_Host_Listings
ORDER BY Number_of_Host_Listings DESC ;


-- Looking to see which room types had the most listings in neighborhood 28806
SELECT Room_Type , COUNT(ID) AS 'Total_Listings_in_Neighborhood_28806' 
FROM bnb_listings bl 
WHERE Neighborhood = 28806
GROUP BY Room_Type
ORDER BY COUNT(ID) DESC ;


-- Looking to see which room types had the most activity in neighborhood 28806
SELECT Room_Type , SUM(Number_of_Reviews) AS 'Total_Reviews_for_Neighborhood_28806'
FROM bnb_listings bl 
WHERE Neighborhood = 28806
GROUP BY Room_Type
ORDER BY COUNT(ID) DESC ;




