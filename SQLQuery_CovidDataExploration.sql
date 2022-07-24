/*
Covid 19 Data Exploration
Data from 01-01-2020 upto 18-07-2022
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4;


--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2;

--Looking at Total cases vs Total deaths
--Chances of dying from contracting covid in each country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location = 'india'
and continent is NOT NULL
ORDER BY 1,2;

--Looking at Total cases vs Population
--Shows what percentage of population has contracted covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location like 'india'
ORDER BY 1,2;

--Looking at countries with highest infection rate

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC;

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population

SELECT Continent, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

--  GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as INT)) AS Total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location = 'india'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Looking at Total population vs vaccinations
-- Shows the Percentage of Population that has recieved at least one Covid Vaccine dose
-- Used Rolling count for new vaccinations per location per date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3;


-- USING CTE
-- Using CTE to perform Calculation on Partition in previous query

WITH PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


--TEMP TABLE
-- Using Temp Table to perform Calculation on Partition in previous query

DROP TABLE if EXISTS #PercentPopulationVaccinated -- If we make alterations in the below query then it would help us to delete the previous temp table and create the new one with the same name
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating a view to store data for later visualizations

DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
