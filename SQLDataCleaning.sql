-- Data Cleaning

SELECT * 
FROM PortfolioProject..layoffs

SELECT * 
FROM PortfolioProject..Layoffs_staging2

-- Creating a separate table to safely edit information 
Create Table Layoffs_staging(
company varchar(50),
location varchar(50),
industry varchar(50),
total_laid_off varchar(50),
percentage_laid_off varchar(50),
date varchar(50),
stage varchar(50),
country varchar(50),
fund_raised_millions varchar(50)
)

-- Copying information over to staging table
INSERT INTO Layoffs_staging
SELECT *
FROM layoffs;

-- Removing duplicates
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date], stage, country, fund_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM PortfolioProject..Layoffs_staging

WITH dupe_cte AS
(
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date], stage, country, fund_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM PortfolioProject..Layoffs_staging
)
SELECT *
FROM dupe_cte
WHERE row_num >1

CREATE TABLE [dbo].[Layoffs_staging2](
	[company] [varchar](50) NULL,
	[location] [varchar](50) NULL,
	[industry] [varchar](50) NULL,
	[total_laid_off] [varchar](50) NULL,
	[percentage_laid_off] [varchar](50) NULL,
	[date] [varchar](50) NULL,
	[stage] [varchar](50) NULL,
	[country] [varchar](50) NULL,
	[fund_raised_millions] [varchar](50) NULL,
	[row_num] [int]
)

INSERT INTO Layoffs_staging2
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date], stage, country, fund_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM PortfolioProject..Layoffs_staging

SELECT * 
FROM PortfolioProject..Layoffs_staging2

-- Standardizing data

-- company
SELECT company, TRIM(company)
FROM PortfolioProject..Layoffs_staging2

UPDATE PortfolioProject..Layoffs_staging2
SET company = TRIM(company)

-- industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1

UPDATE PortfolioProject..Layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'

-- location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1

-- country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1

UPDATE PortfolioProject..Layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

-- date
SELECT [date],
       TRY_CONVERT(DATE, [date], 101) AS converted_date
FROM Layoffs_staging2;

UPDATE PortfolioProject..Layoffs_staging2
SET Date = TRY_CONVERT(DATE, [date], 101)

ALTER TABLE PortfolioProject..Layoffs_staging2 ALTER COLUMN [date] DATE;

-- Editing NULL data (Not sure why the dataset NULL values are strings)
SELECT * 
FROM PortfolioProject..Layoffs_staging2
WHERE total_laid_off = 'NULL' AND percentage_laid_off = 'NULL'

SELECT *
FROM PortfolioProject..Layoffs_staging2
WHERE industry = 'NULL' or industry = '' or industry is NULL

SELECT * 
FROM PortfolioProject..Layoffs_staging2
WHERE company = 'Airbnb'

SELECT * 
FROM PortfolioProject..Layoffs_staging2 t1
JOIN PortfolioProject..Layoffs_staging2 t2
	ON t1.company = t2.company 
	AND t1.location = t2.location
WHERE (t1.industry = 'NULL' or t1.industry = '' or t1.industry is NULL) and (t2.industry != 'NULL' or t2.industry != '' or t2.industry is NOT NULL) 

UPDATE PortfolioProject..Layoffs_staging2
SET industry =  NULL
WHERE industry = ''

UPDATE t1
SET t1.industry = t2.industry
FROM PortfolioProject..Layoffs_staging2 t1
JOIN PortfolioProject..Layoffs_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry = 'NULL' or t1.industry = '' or t1.industry is NULL) and (t2.industry != 'NULL' or t2.industry != '' or t2.industry is NOT NULL) 

-- Deleting rows where total_laid off and percentage_laid off is blank as I deem them unimportant in a layoff database
SELECT * 
FROM PortfolioProject..Layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL'

DELETE
FROM PortfolioProject..Layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL'

ALTER TABLE layoffs_staging2
DROP COLUMN row_num

