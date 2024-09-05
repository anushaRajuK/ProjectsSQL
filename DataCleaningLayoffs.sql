-- Data Cleaning 
-- 1.Remove Duplicates
-- 2.Starndarization 
-- 3.Handling Null and Blank valueas
-- 4.Removing columns(if needed)

-- View the data and understand the data(Raw Data)

SELECT *
FROM layoffs;

-- Create another table for manipulation(Good Practise)

CREATE TABLE layoffs_Staging
LIKE layoffs;

INSERT layoffs_Staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_Staging;

-- --------------------------------------------------------------------------------------------
-- 1.Removing Duplicates (NO unique ID)

-- finding duplicates in the table and storing them in CTE

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_Staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num>1;

-- creating a table to delete the duplicates. 

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_Staging;

SELECT * 
FROM layoffs_staging2;

-- always use the select statement before deleting

SELECT *
FROM layoffs_staging2 
WHERE row_num >1;

DELETE FROM layoffs_staging2 
WHERE row_num >1;

SELECT *
FROM layoffs_staging2;

-- Formatting Data by removing spaces

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Formating Industry column

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

-- Formating country

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Formatting Date

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y' )
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y'); 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- -----------------------------------------------------------------------------------------
-- 3.Handling Null and Blank values

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 K 
JOIN layoffs_staging2 L ON K.company = L.company
WHERE (K.industry IS NULL OR K.industry = '')
AND L.industry IS NOT NULL; 

 UPDATE layoffs_staging2
 SET industry = NULL 
 WHERE industry ='' ;
 
UPDATE layoffs_staging2 K
JOIN layoffs_staging2 L ON K.company = L.company 
SET K.industry = L.industry 
WHERE (K.industry IS NULL) AND  L.industry IS NOT NULL;

-- Deleting Rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 

SELECT *
FROM layoffs_staging2; 
