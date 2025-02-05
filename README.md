# SQL---Analyzing-Unicorn-Companies


## Overview
This project aims to analyze unicorn company data from 2019 to 2021, focusing on identifying the top-performing industries based on the number of new unicorns created during this period. By querying the provided unicorns database, we analyze trends in company valuations, the rate at which new unicorns emerge, and the industries leading this growth. The goal is to provide insights into which industries have the highest valuations and which sectors are seeing the most unicorn creation. These insights can help an investment firm structure its portfolio by understanding industry trends and the emergence of high-value companies.


## Task Summary
The task involves analyzing data from the unicorns database to identify the top-performing industries in terms of new unicorns created during the years 2019, 2020, and 2021. The key objectives were:

1. Identify the three best-performing industries based on the number of new unicorns created in 2019, 2020, and 2021 combined.
2. For these industries, determine the:
   - Number of unicorns per industry
   - Year they became a unicorn
   - Average valuation in billions of dollars (rounded to two decimal places)
3. Return a table with the columns: `industry`, `year`, `num_unicorns`, and `average_valuation_billions`.
4. Sort the results by `year` and `num_unicorns`, both in descending order.

## Database Structure
The unicorns database consists of the following tables:

### 1. `dates`
- `company_id`: Unique ID for the company
- `date_joined`: The date the company became a unicorn
- `year_founded`: The year the company was founded

### 2. `funding`
- `company_id`: Unique ID for the company
- `valuation`: Company valuation in US dollars
- `funding`: Amount of funding raised in US dollars
- `select_investors`: List of key investors

### 3. `industries`
- `company_id`: Unique ID for the company
- `industry`: Industry the company operates in

### 4. `companies`
- `company_id`: Unique ID for the company
- `company`: Name of the company
- `city`: City where the company is headquartered
- `country`: Country where the company is headquartered
- `continent`: Continent where the company is headquartered

## Query
The SQL query below is used to fetch the required results:

```sql
SELECT subquery.industry AS industry,
       EXTRACT(YEAR FROM subquery.date_joined) AS year,
       COUNT(*) AS num_unicorns,
       ROUND(AVG(subquery.valuation/1000000000), 2) AS average_valuation_billions
FROM (SELECT *
      FROM dates AS d
      LEFT JOIN funding AS f
      ON d.company_id = f.company_id
      LEFT JOIN industries AS i
      ON d.company_id = i.company_id
      LEFT JOIN companies AS c
      ON d.company_id = c.company_id
      WHERE EXTRACT(YEAR FROM d.date_joined) BETWEEN 2019 AND 2021) AS subquery
WHERE industry IN (SELECT industry
                   FROM industries
                   GROUP BY industry
                   ORDER BY COUNT(industry) DESC
                   LIMIT 3)
GROUP BY industry, year
ORDER BY year DESC, num_unicorns DESC;
```

### Query Breakdown
- The query selects the industry, the year a company joined (converted from date_joined), the count of unicorns (num_unicorns), and the average valuation (in billions, rounded to two decimal places).
- A subquery is used to join the relevant tables (dates, funding, industries, and companies) to filter companies that became unicorns in 2019, 2020, or 2021.
- The industries are filtered to only include the top three industries based on the number of unicorns.
- The results are grouped by industry and year, and sorted in descending order by year and number of unicorns.


## Results
The query returns the following table:

| Industry                               | Year | Num Unicorns | Average Valuation (Billions) |
|----------------------------------------|------|--------------|------------------------------|
| Fintech                                | 2021 | 138          | 2.75                         |
| Internet software & services           | 2021 | 119          | 2.15                         |
| E-commerce & direct-to-consumer        | 2021 | 47           | 2.47                         |
| Internet software & services           | 2020 | 20           | 4.35                         |
| E-commerce & direct-to-consumer        | 2020 | 16           | 4.00                         |
| Fintech                                | 2020 | 15           | 4.33                         |
| Fintech                                | 2019 | 20           | 6.80                         |
| Internet software & services           | 2019 | 13           | 4.23                         |
| E-commerce & direct-to-consumer        | 2019 | 12           | 2.58                         |

## Results in Graphics
### Average Valuation (Billions USD) by Industry and Year
![image](https://github.com/user-attachments/assets/edd3d9ca-116a-459e-b892-58ca2bb685a6)

### Number of Unicorns by Industry and Year
![image](https://github.com/user-attachments/assets/98f3c1bb-81b7-47cd-ac69-f6f750b8b73d)


## Conclusion
Based on the analysis of unicorn data from 2019 to 2021, we can conclude that the **Fintech** industry has the highest number of unicorns, with an impressive average valuation that peaked in 2019 at 6.80 billion dollars. The **Internet Software & Services** and **E-commerce & Direct-to-Consumer** industries also show strong performances, with consistent unicorn creation across all three years. This information provides valuable insights for the investment firm to structure their future investment strategy.
