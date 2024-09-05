-- Exploratory Data Analysis 

SELECT *
FROM layoffs_staging2;

/*Dataset conatains the layoffs between March 2020 to March 2023*/
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

/* Big Companies completly went under */ 
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY  funds_raised_millions DESC;


/*Total Employee layoffs from each company*/
SELECT company, SUM(total_laid_off) AS total_employees_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

/*Total Employee layoffs based on Industries*/
SELECT industry, SUM(total_laid_off) AS total_employees_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_employees_laid_off DESC;

/*Total Employee layoffs in countries around the world*/
SELECT country , SUM(total_laid_off) AS total_employees_laid_off
FROM layoffs_staging2
GROUP BY country 
ORDER BY total_employees_laid_off DESC;

/*Total Employees laid off in each year*/
SELECT YEAR(`date`), SUM(total_laid_off) AS total_employees_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

/*Total employees laid off based on the stage of the company */
SELECT stage, SUM(total_laid_off) AS total_employees_laid_off
FROM layoffs_staging2
GROUP BY stage 
ORDER BY 2 DESC;

/*Rolling total of layoffs */

WITH  rolling_total AS (
SELECT substring(`date`, 1,7) AS `MONTH` , SUM(total_laid_off) AS total_lay_offs
FROM layoffs_staging2
WHERE substring(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,total_lay_offs, SUM(total_lay_offs) OVER(ORDER BY `MONTH`) AS rolling_total
FROM rolling_total;

/*Highest Layoffs of companies each year */

SELECT company, substring(`date`,1,4) AS `YEAR`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , `YEAR`
ORDER BY 3 DESC;

/*Ranking Highest Layoffs in each year from companies*/

WITH company_layoff_years AS(
SELECT company, substring(`date`,1,4) AS `YEAR`, SUM(total_laid_off) AS total_lay_offs
FROM layoffs_staging2
WHERE substring(`date`,1,4) IS NOT NULL
GROUP BY company , `YEAR`
ORDER BY 3 DESC
), company_year_rank AS
(
SELECT * , DENSE_RANK() OVER(PARTITION BY `YEAR` ORDER BY  total_lay_offs DESC) AS ranking
FROM company_layoff_years
)
SELECT *
FROM company_year_rank 
WHERE ranking < 6;

