SELECT * FROM `porfolio project`.coviddeaths
where continent is not null
order by 3,4 ;

SELECT * FROM `porfolio project`.covidvaccinations
order by 3,4 ;


select  location, date, total_cases, new_cases, total_deaths, population
from `porfolio project`.coviddeaths
where continent IS NOT NULL AND continent <> ''
order by 3,4; 

-- looking at Total cases vs Ttotal Deaths
-- Shows likeihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from `porfolio project`.coviddeaths
where location like "india" and  continent IS NOT NULL AND continent <> ''
order by 1,2; 

-- Looking at Total cases vs Population
-- Shows what Percentage got covid

select location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
from `porfolio project`.coviddeaths
 where location like "india" and  continent IS NOT NULL AND continent <> ''
order by 1,2; 

-- Looking at Countries with Highest Infection Rate Copared to population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as populationPercentageInfected
from `porfolio project`.coviddeaths
where continent IS NOT NULL AND continent <> ''
group by location , population
order by populationPercentageInfected desc;

-- showing countries with highest deaths count per population

SELECT location, 
       MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM `porfolio project`.coviddeaths
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY location
ORDER BY TotaldeathCount DESC;


-- LET'S BREAK THINGS DWON BY CONTINENT
-- showing the continents with the highest death count per population

SELECT continent,
       MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM `porfolio project`.coviddeaths
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
ORDER BY TotaldeathCount DESC;


-- Global numbers
select  sum(new_cases) as Total_cases , sum(new_deaths) as Total_deaths,sum(new_deaths)/sum(new_cases)*100 as DeathsPercentage
from `porfolio project`.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- group by date
order by 1,2; 

-- looking at total population vs vaccinations

SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY d.location 
        ORDER BY d.location, d.date
    ) AS Rolling_total_vaccinations
FROM `porfolio project`.coviddeaths d
JOIN `porfolio project`.covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL 
  AND d.continent <> ''
ORDER BY d.location, d.date;

-- USE CTE
with popvsvac(continent, location, date, population, new_vaccinations,Rolling_total_vaccinations)
as (
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY d.location 
        ORDER BY d.location, d.date
    ) AS Rolling_total_vaccinations
FROM `porfolio project`.coviddeaths d
JOIN `porfolio project`.covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL 
  AND d.continent <> ''
)
select *, (Rolling_total_vaccinations /population)*100 from popvsvac;

-- Temp table
USE `porfolio project`;

DROP TABLE IF exists PrecentagePopulationVacconation;
CREATE TABLE PrecentagePopulationVacconation (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);




INSERT INTO PrecentagePopulationVacconation
SELECT  
    d.continent,  
    d.location,  
    d.date,  
    d.population,  
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY d.location  
        ORDER BY d.location, d.date
    ) AS rollingpeoplevaccinated
FROM `porfolio project`.coviddeaths d
JOIN `porfolio project`.covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
-- WHERE d.continent IS NOT NULL  
  AND d.continent <> '';
SELECT *, 
       (rollingpeoplevaccinated / population) * 100 AS PercentageVaccinated
FROM PrecentagePopulationVacconation;

-- CREATEING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE view PercentagePopulationVaccinated as
SELECT  
    d.continent,  
    d.location,  
    d.date,  
    d.population,  
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY d.location  
        ORDER BY d.location, d.date
    ) AS rollingpeoplevaccinated
FROM `porfolio project`.coviddeaths d
JOIN `porfolio project`.covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL  
  AND d.continent <> '';


SELECT * FROM `porfolio project`.percentagepopulationvaccinated;
