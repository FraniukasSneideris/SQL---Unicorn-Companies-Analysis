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
