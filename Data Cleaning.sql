-- Data Cleaning 

-- 1. Remove duplicates 
-- 2. Standardize the Data
-- 3. Work with Null Values or blank values 
-- 4. Remove any unnecessary colums and rows 

SELECT*
FROM layoffs; 

CREATE TABLE layoffs_staging 
LIKE layoffs; 

SELECT*
FROM layoffs_staging; 

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date', country) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT*
FROM duplicate_cte
WHERE row_num > 1;

SELECT*
FROM layoffs_staging
;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT*
FROM layoffs_staging2
; 

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE `row-num` > 1; 

-- STANDARDIZING DATA 

SELECT company,
TRIM(company)
From layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1; 

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location 
FROM layoffs_staging2
ORDER BY 1; 

UPDATE layoffs_staging2
SET location = 'Malmo' 
WHERE location LIKE 'MalmÃ¶';

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y'); 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Removing NULLS

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL; 

SELECT distinct industry, company
FROM layoffs_staging2
ORDER BY 1;

-- now because we have 2 colums with a lot of nulls rows in and we cant trust the data, we can remove it also

SELECT*
FROM layoffs_staging2
WHERE total_laid_off is NULL OR total_laid_off = ''
AND percentage_laid_off IS NULL OR percentage_laid_off = '';

DELETE 
FROM layoffs_staging2
WHERE total_laid_off is NULL OR total_laid_off = ''
AND percentage_laid_off IS NULL OR percentage_laid_off = '';

SELECT*
FROM layoffs_staging2;

-- Removing unnessesary column

ALTER TABLE layoffs_staging2
DROP COLUMN `row-num`;

ALTER TABLE layoffs_staging2
DROP COLUMN `row-num`;