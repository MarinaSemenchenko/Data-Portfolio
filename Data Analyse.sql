-- Analysis of Employee Layoffs Across Companies and Countries

-- This project involves analyzing data on mass employee layoffs across various companies and countries from 2020 to 2023. 
-- The goal was to explore trends and patterns in layoffs by analyzing different factors such as company, country, industry, time, etc. 
-- SQL queries were used to aggregate and filter the data, and the project provides insights into key trends and insights based on the findings.

-- Start Point
SELECT*
FROM layoffs_staging2; 

-- Determine the maximum number of layoffs and percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

--  Sort data by the total number of layoffs in descending order, allowing us to identify which companies had the largest layoffs.
SELECT*
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER by total_laid_off DESC; 

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; 

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;  -- lookes like US fired much more people than other countries started from 2020 till 2023 

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC; -- 2022 most of the people have been fired for now 

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Rolling total of layoffs by month, helping us identify significant spikes in layoffs. 
-- From the results, we saw major increases starting from 05-2022 and more pronounced increases from 10-2022.
SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS 
(SELECT substring(`date`,1,7) AS `MONTH`, 
SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

--  Rolling total of layoffs by years to observe trends over time and which companies had the most layoffs in each year.

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 

-- Rank companies by total layoffs for each year, helping to identify the companies with the largest layoffs.

WITH company_year (company, years, total_laid_off) AS 
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT*, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL 
ORDER BY ranking ASC; 

--  Filter top 5 companies with the most layoffs per year, making it easier to focus on the companies with the largest impact.

WITH company_year (company, years, total_laid_off) AS 
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT*, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL 
)
SELECT*
FROM Company_Year_Rank
WHERE ranking <=5
ORDER BY total_laid_off DESC;

-- Results and Interpretation:
-- Largest layoffs were observed in USA, with the highest number of layoffs in 2022 and 2023.
-- In 2022, there was a significant spike in layoffs, marking it as the peak year for mass employee terminations.
-- The Consumer and Retail sector experienced the highest number of layoffs during 2022, highlighting the sector's struggles.
-- Top companies with the most layoffs include Google, Meta, and Amazon, with the highest layoffs occurring in 2023.















