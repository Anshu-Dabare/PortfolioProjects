SELECT * 
FROM PortfolioProject..CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases VS Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases VS Population
--what percentage of population got Covid
SELECT location, date, total_deaths, population, total_cases, (total_cases/population)*100 AS CasePerPopulation 
FROM PortfolioProject..CovidDeaths
order by 1,2

--lookng at countries with highest Infection rate compared to population
SELECT location, population,  MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)*100 AS InfectionPerPopulation
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
--HAVING location LIKE '%India%'
ORDER BY 4 DESC

--lets braek things down by continent

--showing the continent with highest death count 
SELECT continent, MAX(cast(total_deaths AS int))AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not null
GROUP BY continent
ORDER BY HighestDeathCount desc

--Global numbers

SElect date, SUM(new_cases) AS totalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS deathPerCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

SElect  SUM(new_cases) AS totalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS deathPerCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2


--looking at total population VS vaccination

--with CTE
 WITH PopVSvacc (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
 AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location=vac.location
   and dea.date=vac.date
   WHERE dea.continent IS NOT null
   --ORDER BY 2,3
   )
SELECT *,(RollingPeopleVaccinated/population)*100 AS vaccinationPerPopulation
FROM PopVSvacc

--TEMP table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent varchar(255),
location varchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location=vac.location
   and dea.date=vac.date
   WHERE dea.continent IS NOT null

SELECT *,(RollingPeopleVaccinated/population)*100 AS vaccinationPerPopulation
FROM #PercentPopulationVaccinated


--creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location=vac.location
   and dea.date=vac.date
   WHERE dea.continent IS NOT null

SELECT *
FROM PercentPopulationVaccinated


   