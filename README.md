# Maven-Analytics-NYC-TAXI-CHALLENGE

Link to challenge:- https://www.mavenanalytics.io/blog/maven-taxi-challenge

![image](https://user-images.githubusercontent.com/13623073/153695499-c9be56a0-e11f-4c5d-a841-848db6a5e6bf.png)

For the Maven Taxi Challenge, you’ll be playing the role of a new Data Analyst for the New York City Taxi & Limousine Commission.

# About the dataset
This dataset contains 6 tables in csv format, along with a geospatial map in TopoJSON and Shapefile formats

- The 4 Taxi Trips tables contain a total of 28 million Green Taxi trips in New York City from 2017 to 2020. Each record represents one trip, with fields containing details about the pick-up/drop-off times and locations, distances, fares, passengers, and more
- The 454 Calendar table contains a fiscal calendar (2017-2020) used by the Taxi & Limousine Commission, with fields containing the date and fiscal year, quarter, month, and week
- The Taxi Zones table contains information about 265 zone locations in New York City, including the location id, borough, and service zone
- The Taxi Zones Map files contain a map of New York City with divisions for the 265 locations that can be used to create custom map visuals in Power BI (TopoJSON) or Tableau (Shapefile)

# Data Prep and Cleaning Requirements
 - Stick to trips that were NOT sent via “store and forward”
- I’m only interested in street-hailed trips paid by card or cash, with a standard rate
- Remove any trips with dates before 2017 or after 2020, along with any trips with pickups or drop-offs into unknown zones
- Assume  any trips with no recorded passengers had 1 passenger
- If a pickup date/time is AFTER the drop-off date/time, let’s swap them
- We can remove trips lasting longer than a day, and any trips which show both a distance and fare amount of 0
- If you notice any records where the fare, taxes, and surcharges are ALL negative, please make them positive
- For any trips that have a fare amount but have a trip distance of 0, calculate the distance this way: (Fare amount - 2.5) / 2.5
- For any trips that have a trip distance but have a fare amount of 0, calculate the fare amount this way: 2.5 + (trip distance x 2.5)

# Questions to answer when creating the dashboard
- What's the average number of trips we can expect this week?
- What's the average fare per trip we expect to collect?
- What's the average distance traveled per trip?
- How do we expect trip volume to change, relative to last week?
- Which days of the week and times of the day will be busiest?
- What will likely be the most popular pick-up and drop-off locations?
