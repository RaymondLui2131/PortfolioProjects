
SELECT * 
FROM PortfolioProject..CovidDeaths

SELECT * 
FROM PortfolioProject..CovidVaccinations

SELECT * 
FROM PortfolioProject..CovidPopulation

SELECT Location, date, total_cases, new_cases, total_deaths, total_cases
FROM PortfolioProject..CovidDeaths
ORDER BY date

SELECT Location, date, people_vaccinated, people_fully_vaccinated
FROM PortfolioProject..CovidVaccinations

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / NULLIF(total_cases,0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY DATE

-- Looking at Total cases vs Population
-- Shows what percentage of the population got covid
SELECT location, date, population, total_cases, (total_cases / NULLIF(population,0))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY DATE

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / NULLIF(population,0)))*100 AS HighestInfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY population desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing Death Count of each continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths as float)) AS TotalNewDeaths, (SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100) AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
DROP TABLE if Exists #PopulationVsVaccinations
Create Table #PopulationVsVaccinations(
Continent varchar(50),
Location varchar(50),
Population float,
New_Vaccinations float,
RollingPeopleVaccinated float,
date date
)
INSERT INTO #PopulationVsVaccinations
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated, vac.date
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '' 
Select *, (RollingPeopleVaccinated/ NULLIF(Population,0))*100 AS PercentageOfPopulationVaccinated
FROM #PopulationVsVaccinations

-- Creating View to store data for later visualizations
USE PortfolioProject
GO
CREATE VIEW PercentageOfPopVaccinated as
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '' 



