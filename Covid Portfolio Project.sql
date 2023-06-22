-- Selecting all data from CovidDeaths Table

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Selecting all data from CovidVaccinations Table

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- shows the likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS NUMERIC)/CAST(total_cases AS NUMERIC))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Kenya'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percantage of population got covid

SELECT location, date, population, total_cases, (CAST(total_cases as numeric))/(population)*100 as PopulationPercentageInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(CAST(total_cases as numeric)))/(population)*100 as MaxPercentageInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxPercentageInfected DESC


-- Showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS DeathCountPerContinent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCountPerContinent DESC




-- Global Numbers

SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  CASE WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100 ELSE 0 END AS death_rate
FROM
  CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global numbers of total case total deaths and death rate percentage for the whole world
SELECT
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  CASE WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100 ELSE 0 END AS death_rate
FROM
  CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Joining the tables

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- looking at Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTEs

WITH PopvsVac (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS numeric)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS numeric)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS numeric)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated