# SQL and Python---Unicorn-Companies-Data Analysis Comparison


## Overview
This project aims to analyze unicorn company data from 2019 to 2021, focusing on identifying the top-performing industries based on the number of new unicorns created during this period. By querying the provided unicorns database, we analyze trends in company valuations, the rate at which new unicorns emerge, and the industries leading this growth. The goal is to provide insights into which industries have the highest valuations and which sectors are seeing the most unicorn creation. These insights can help an investment firm structure its portfolio by understanding industry trends and the emergence of high-value companies.

While initially thought for SQL analysis, I decided to perform the analysis both with SQL and Python to compare both approaches.


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

## SQL Analysis
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

## Python Analysis
```python
import pandas as pd

# Loading the data
dates = pd.read_csv("dates.csv")
funding = pd.read_csv("funding.csv")
industries = pd.read_csv("industries.csv")
companies = pd.read_csv("companies.csv")

# Merging all tables
all_dfs = dates.merge(funding, on="company_id", how="left") \
               .merge(industries, on="company_id", how="left") \
               .merge(companies, on="company_id", how="left")

# Parsing date_joined and extract year
all_dfs["date_joined"] = pd.to_datetime(all_dfs["date_joined"])
all_dfs["year"] = all_dfs["date_joined"].dt.year

# Filtering unicorns based on date_joined year
unicorns_year = all_dfs[all_dfs["year"].isin([2019, 2020, 2021])]

# Determining top 3 industries based on filtered data 
top_three_ind = unicorns_year.groupby("industry")["company_id"].count().sort_values(ascending=False).head(3)
top_industries = top_three_ind.index.tolist()

# Filtering for top 3 industries
unicorns_filtered = unicorns_year[unicorns_year["industry"].isin(top_industries)]

# Grouping and aggregating
unicorns_grouped = unicorns_filtered.groupby(["industry", "year"]).agg(
    num_unicorns=("company_id", "count"),
    average_valuation_billions=("valuation", lambda x: round(x.mean() / 1000000000, 2))
).sort_values(by=["year", "num_unicorns"], ascending=[False, False])
```

### Python Analysis Breakdown
The Python code above replicates the same logic as the SQL query using pandas. After loading the datasets, it merges them using merge() with how="left" to simulate SQL left joins. The pd.to_datetime() function is used to convert the date_joined column into a datetime format, and .dt.year is applied to extract the year. The dataset is then filtered to include only unicorns from the years 2019 to 2021 using boolean indexing with .isin(). To determine the top three industries by unicorn count, the code uses groupby() and count() followed by sort_values() and head(3), then extracts the industry names with .index.tolist(). Another filtering step keeps only the rows belonging to these top industries. Finally, the data is grouped again by industry and year using groupby().agg() to calculate both the number of unicorns and the average valuation in billions (using a lambda function and mean()), and the final result is sorted with sort_values() by year and count in descending order.

---

## Comparison of SQL and Python Methods

Both SQL and Python (using pandas) follow a similar logical process to extract and process the data, but they achieve it using different methods. Below is a breakdown of how each step is handled in both approaches:


#### 1. **Data Joining**
- **SQL:** Uses `LEFT JOIN` to combine multiple tables on the `company_id` column.
- **Python:** Uses `merge(how="left")` multiple times to replicate the left join behavior and combine all datasets.


#### 2. **Filtering by Year**
- **SQL:** Applies `WHERE EXTRACT(YEAR FROM date_joined) BETWEEN 2019 AND 2021` to filter the data.
- **Python:** Converts the `date_joined` column to datetime using `pd.to_datetime()`, extracts the year using `.dt.year`, and filters the DataFrame using `.isin([2019, 2020, 2021])`.


#### 3. **Finding Top 3 Industries**
- **SQL:** Uses a subquery with `GROUP BY industry` and `ORDER BY COUNT(industry) DESC LIMIT 3` to identify the top 3 industries by unicorn count.
- **Python:** Uses `groupby("industry")["company_id"].count().sort_values(ascending=False).head(3)` to get top industries, then extracts their names with `.index.tolist()`.


#### 4. **Grouping and Aggregation**
- **SQL:** Groups results by `industry` and `year`, then computes:
  - `COUNT(*)` for number of unicorns.
  - `ROUND(AVG(valuation/1000000000), 2)` for average valuation in billions.
- **Python:** Uses `.groupby(["industry", "year"]).agg()` to:
  - Count unicorns with `("company_id", "count")`.
  - Compute average valuation with a lambda function: `lambda x: round(x.mean() / 1_000_000_000, 2)`.


#### 5. **Sorting Results**
- **SQL:** Orders the final output with `ORDER BY year DESC, num_unicorns DESC`.
- **Python:** Applies `.sort_values(by=["year", "num_unicorns"], ascending=[False, False])` to achieve the same sorting logic.


### Key Differences

- **Declarative vs Imperative:**  
  SQL is a declarative language that specifies *what* you want, while pandas in Python is imperative and requires step-by-step *how* instructions.

- **Type Handling:**  
  Python requires explicit conversions (e.g., `pd.to_datetime()`), whereas SQL has built-in date functions like `EXTRACT(YEAR FROM ...)`.

- **Filtering Strategy:**  
  SQL uses nested subqueries to filter data, while pandas separates filtering into intermediate steps using list extraction and boolean masks.

- **Environment:**  
  SQL operates on a database server and is optimized for large-scale querying.  
  pandas works in-memory and offers more flexibility for custom logic and data manipulation in Python scripts or Jupyter notebooks.


Both methods lead to the same analytical result but highlight different strengths:
- SQL is concise and efficient for querying relational databases.
- pandas provides powerful data manipulation tools for more programmatic and customizable analysis.

---

## Results
Both methods return the following table:

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
![image](https://github.com/user-attachments/assets/cadf9521-aaf9-4b8c-8837-cc7e379e0287)

![image](https://github.com/user-attachments/assets/4e1de132-7961-47bf-bc20-8fa5aa5a943c)



## Conclusion
Based on the analysis of unicorn data from 2019 to 2021, we can conclude that the **Fintech** industry has the highest number of unicorns, with an impressive average valuation that peaked in 2019 at 6.80 billion dollars. The **Internet Software & Services** and **E-commerce & Direct-to-Consumer** industries also show strong performances, with consistent unicorn creation across all three years. This information provides valuable insights for the investment firm to structure their future investment strategy.
