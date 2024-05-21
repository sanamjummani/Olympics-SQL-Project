# Olympics-SQL-Project
Querying "120 years of Olympic History" Dataset from Kaggle using SQL

Olympics Games and Athletes SQL Queries

Welcome to the SQL querying project for the Olympics Games and Athletes dataset. This dataset spans from the first modern Olympic Games in 1896 to the 2016 Games. The aim of this project is to provide SQL queries that can be used to extract and analyze various aspects of the Olympic Games and athletes' performance over this period.

## Table of Contents
1. [Dataset Description]
2. [Installation/Uploading Dataset on Postgre SQL]
3. [Database Schema]
4. [Queries])
5. [Contributing]

## Dataset Description

The dataset includes information on:
- Athletes: Name, gender, nationality, weight, height etc.
- Events: Sport, event name, etc.
- Results: Medals won, etc.
- Games: Year, season, city, etc.

The data has been sourced from [Kaggle](https://www.kaggle.com/heesoo37/120-years-of-olympic-history-athletes-and-results).

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/Olympics-SQL-Project.git
    cd Olympics-SQL-Project
   ```

2. **Load the dataset into a SQL database:**
   - Ensure you have a running instance of a SQL database (e.g., MySQL, PostgreSQL).
   - Create a database (e.g., `olympics_db`).
   - Import the dataset into the database according to the RDBMS you are using.     

3. **Run the SQL scripts:**
   - Execute the SQL scripts provided in the `queries` directory to perform various analyses.

## Database Schema

The database consists of the following 2 tables/files:

  1) The file athlete_events.csv contains 271116 rows and 15 columns. Each row corresponds to an individual athlete competing in an individual Olympic event (athlete-events). The columns are:

  ID - Unique number for each athlete
  Name - Athlete's name
  Sex - M or F
  Age - Integer
  Height - In centimeters
  Weight - In kilograms
  Team - Team name
  NOC - National Olympic Committee 3-letter code
  Games - Year and season
  Year - Integer
  Season - Summer or Winter
  City - Host city
  Sport - Sport
  Event - Event
  Medal - Gold, Silver, Bronze, or NA

  2) The file noc_regions.csv contains
     
  NOC (National Olympic Committee 3 letter code)
  Country name (matches with regions in map_data("world"))
  Notes


## Queries
I have made a separate file for SQL queries and their scripts. 

## Contributing

We welcome contributions from the community. If you have any ideas or improvements, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new comment'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.


---

Thank you for visiting this repository. Happy querying!

---

For any queries or issues, please open an issue in this repository or contact me at sanamajeed58@gmail.com.
