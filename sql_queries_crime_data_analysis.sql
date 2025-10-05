use crime_data_analysis;

CREATE TABLE ipc_crimes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  state_ut VARCHAR(100),
  year INT,
  crimes INT,
  population_lakh DECIMAL(9,1),
  rate_ipc DECIMAL(7,1),
  chargesheet_rate DECIMAL(5,1)
);

SELECT year, COUNT(*) row_count, SUM(crimes) total_crimes
FROM ipc_crimes
GROUP BY year;

SELECT COUNT(DISTINCT state_ut) FROM ipc_crimes;

SELECT year, COUNT(population_lakh IS NOT NULL OR NULL) AS pop_nonnull
FROM ipc_crimes
GROUP BY year;

SELECT state_ut, crimes FROM ipc_crimes WHERE year=2022 ORDER BY crimes DESC LIMIT 5;

CREATE INDEX idx_year ON ipc_crimes(year);    --#Makes queries that filter or sort by year much faster.

CREATE INDEX idx_state ON ipc_crimes(state_ut);

SELECT * FROM ipc_crimes WHERE year = 2020;

SELECT * FROM ipc_crimes WHERE state_ut = 'Andhra Pradesh';


#1) Yearly crime trend (already checked but keeping for reference)

SELECT year, SUM(crimes) AS total_crimes
FROM ipc_crimes
GROUP BY year
ORDER BY year;

#2) Top 5 states with highest crimes in 2022

SELECT state_ut, crimes
FROM ipc_crimes
WHERE year = 2022
ORDER BY crimes DESC
LIMIT 5;

#3) Bottom 5 states with lowest crimes in 2022

SELECT state_ut, crimes
FROM ipc_crimes
WHERE year = 2022
ORDER BY crimes ASC
LIMIT 5;

#4) Growth rate of crimes (2020 → 2022) per state

SELECT state_ut,
       MAX(CASE WHEN year=2020 THEN crimes END) AS crimes_2020,
       MAX(CASE WHEN year=2022 THEN crimes END) AS crimes_2022,
       ROUND(((MAX(CASE WHEN year=2022 THEN crimes END) - 
               MAX(CASE WHEN year=2020 THEN crimes END)) * 100.0 /
               MAX(CASE WHEN year=2020 THEN crimes END)),2) AS pct_change
FROM ipc_crimes
GROUP BY state_ut
ORDER BY pct_change DESC;

#5) Per capita crimes (2022 only)

SELECT state_ut,
       crimes,
       population_lakh,
       ROUND(crimes / population_lakh, 2) AS crimes_per_lakh
FROM ipc_crimes
WHERE year = 2022
ORDER BY crimes_per_lakh DESC;

#6) States with highest chargesheeting rate (2022)

SELECT state_ut, chargesheet_rate
FROM ipc_crimes
WHERE year = 2022
ORDER BY chargesheet_rate DESC
LIMIT 5;

#7) Compare state crime rate vs national average (2022)

SELECT state_ut,
       rate_ipc,
       (SELECT AVG(rate_ipc) 
        FROM ipc_crimes WHERE year=2022) AS national_avg_rate,
       rate_ipc - (SELECT AVG(rate_ipc) 
                   FROM ipc_crimes WHERE year=2022) AS diff_from_avg
FROM ipc_crimes
WHERE year = 2022
ORDER BY diff_from_avg DESC;

#8) Year-on-year percentage change (2020–2021–2022)

SELECT state_ut, 
       SUM(CASE WHEN year=2020 THEN crimes END) AS crimes_2020,
       SUM(CASE WHEN year=2021 THEN crimes END) AS crimes_2021,
       SUM(CASE WHEN year=2022 THEN crimes END) AS crimes_2022,
       ROUND(((SUM(CASE WHEN year=2021 THEN crimes END) -
               SUM(CASE WHEN year=2020 THEN crimes END)) * 100.0 /
               SUM(CASE WHEN year=2020 THEN crimes END)),2) AS pct_change_20_21,
       ROUND(((SUM(CASE WHEN year=2022 THEN crimes END) -
               SUM(CASE WHEN year=2021 THEN crimes END)) * 100.0 /
               SUM(CASE WHEN year=2021 THEN crimes END)),2) AS pct_change_21_22
FROM ipc_crimes
GROUP BY state_ut
ORDER BY pct_change_21_22 DESC;

#9) States where crimes decreased in 2022 vs 2021

SELECT state_ut, 
       SUM(CASE WHEN year=2021 THEN crimes END) AS crimes_2021,
       SUM(CASE WHEN year=2022 THEN crimes END) AS crimes_2022
FROM ipc_crimes
GROUP BY state_ut
HAVING crimes_2022 < crimes_2021
ORDER BY crimes_2021 DESC;

#10) Rank states by IPC Rate & Chargesheeting Rate (2022)

SELECT state_ut,
       rate_ipc,
       RANK() OVER (ORDER BY rate_ipc DESC) AS rank_by_ipc,
       chargesheet_rate,
       RANK() OVER (ORDER BY chargesheet_rate DESC) AS rank_by_chargesheet
FROM ipc_crimes
WHERE year = 2022
ORDER BY rank_by_ipc;