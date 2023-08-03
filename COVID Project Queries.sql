---- COVID PROJECT QUERIES ----

--- DEATH QUERIES ---

-- Looking at the daily death percentage per country:

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DailyDeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at the total death count per country, compared to its respective continent:

SELECT location, continent, MAX(cast(total_deaths as int)) as CountryDeathCount, SUM(MAX(cast(total_deaths as int))) OVER (PARTITION BY continent ORDER BY (SELECT NULL)) as ContinentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, continent
ORDER BY continent, CountryDeathCount DESC


-- Looking at total death percentage compared to its respective continent:
--- Multipled the column by 1 to get the correct decimal value

WITH CTE_DeathCountComparison as
	(SELECT location, continent, MAX(cast(total_deaths as int)) as CountryDeathCount, SUM(MAX(cast(total_deaths as int))) OVER (PARTITION BY continent ORDER BY (SELECT NULL)) as ContinentDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY location, continent
	)
SELECT location, continent, ((CountryDeathCount*1.0)/ContinentDeathCount)*100 as DeathRateContinent
FROM CTE_DeathCountComparison
ORDER BY continent, DeathRateContinent DESC


-- Looking at the DAILY global death percentage:
--- Used a workaround with the 'new_cases' column

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DailyGlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date


-- Looking at the OVERALL global death percentage:
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null


-- Looking at the total death percentage per country, with total death count:

SELECT location, population, continent, MAX(cast(total_deaths as int)) as CountryDeathCount, (MAX(cast(total_deaths as int))/population)*100 as PercentPopulationDead
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, continent, population
ORDER By PercentPopulationDead DESC

-- Looking at the timeline of the population death rate:

SELECT location, population, continent, date, MAX(cast(total_deaths as int)) as CountryDeathCount, SUM(MAX(cast(total_deaths as int))) OVER (PARTITION BY continent ORDER BY (SELECT NULL)) as ContinentDeathCount, (MAX(cast(total_deaths as int))/population)*100 as PercentPopulationDead
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, continent, population, date
ORDER By PercentPopulationDead DESC


--- INFECTION QUERIES ---

-- Looking at the overall total infection rate for an individual country

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1, 2

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Guyana'
ORDER BY 1, 2


-- Looking at countries with the overall highest total infection rates, alongside their highest infection count

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at total country population, and world population

SELECT continent, location, population as country_population, SUM(population) OVER () as world_population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY population DESC

-- Looking at total country population as a percentage of the world population
--- Used the previous query to find the total world population count
SELECT continent, location, population as country_population, population/7844980051*100 as PercentWorldPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY population DESC


-- Looking at the total global infection percentage
--- Used a previous query to find the total world population

SELECT SUM(new_cases) as total_cases, (SUM(new_cases)/7844980051)*100 as GlobalInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Looking at the timeline of the population infection rate

SELECT location, population, continent, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
	and location not in ('World', 'European Union', 'International')
	and location not like ('%income%')
GROUP BY location, population, continent, date
ORDER BY PercentPopulationInfected DESC


--- VACCINATION QUERIES (Vaccines Administered) ---

-- Looking at the total amount of new vaccinations administered daily, per country

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE death.continent is not null
ORDER BY 2, 3


-- Looking at number of new vaccinations administered per date, for a specific country:

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE vax.location = 'Canada'
ORDER BY 2, 3


-- Looking at the total new vaccinations administered per date, and overall rolling total per country:

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY death.location order by death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE death.continent is not null
ORDER BY 2, 3


--- VACCINATION QUERIES (Fully Vaccinated) ---

-- Looking at the population of Canada that is fully vaccinated (cumulative totals, not individually per day)

SELECT death.continent, death.location, death.date, death.population, vax.people_fully_vaccinated, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE vax.location = 'Canada'
ORDER BY 2, 3


-- Looking at the population of Guyana that is fully vaccinated (cumulative totals, not individually per day)

SELECT death.continent, death.location, death.date, death.population, vax.people_fully_vaccinated, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE vax.location = 'Guyana'
ORDER BY 2, 3

-- Looking at the total fully vaccinated count per country

SELECT location, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
GROUP BY location
ORDER By FullVaxPop desc

-- Looking at the total fully vaccinated count per continent

SELECT location, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxCont
FROM PortfolioProject..CovidVaccinations
WHERE continent is null
	and location not in ('World', 'European Union', 'International')
	and location not like ('%income%')
GROUP BY location
ORDER BY FullVaxCont desc

-- Looking at the total global population fully vaccinated rate

WITH CTE_GlobalFullVax as
	(SELECT location, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop
	FROM PortfolioProject..CovidVaccinations
	WHERE continent is not null
	GROUP BY location
	)
SELECT SUM(FullVaxPop) as GlobalFullVax, (SUM(FullVaxPop)/7844980051)*100 as GlobalFullVaxPercent
FROM CTE_GlobalFullVax
ORDER By GlobalFullVax desc

-- Looking at the timeline of the fully vaccinated rate

SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE death.continent is not null
GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
ORDER BY FullVaxPercent desc


-- Looking at the percent of a country's population fully vaccinated (using CTE)

WITH CTE_Vaxx as 
	(SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent, MAX((vax.people_fully_vaccinated/death.population)*100) as max_vax
	FROM PortfolioProject..CovidDeaths as death
	JOIN PortfolioProject..CovidVaccinations as vax
		on death.location = vax.location
		and death.date = vax.date
	WHERE death.continent is not null
	GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
	)
SELECT location, population, MAX(max_vax) as FullVaxPercent, continent
FROM CTE_vaxx
WHERE continent is not null
GROUP BY location, continent, population
ORDER by FullVaxPercent desc


-- Looking at the average of the world population fully vaccinated (using a CTE)

WITH CTE_Vaxx as 
	(SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent, MAX((vax.people_fully_vaccinated/death.population)*100) as max_vax
	FROM PortfolioProject..CovidDeaths as death
	JOIN PortfolioProject..CovidVaccinations as vax
		on death.location = vax.location
		and death.date = vax.date
	WHERE death.continent is not null
	GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
	)
SELECT AVG(FullVaxPercent) OVER () as AVGWorldFullyVaxxed 
FROM
	(SELECT location, population, MAX(max_vax) as FullVaxPercent, continent
	FROM CTE_vaxx
	WHERE continent is not null
	GROUP BY location, continent, population) as subq


-- Looking at countries ABOVE the world average (using a CTE)
--- Used the previous query result to calculate those above average

WITH CTE_Vaxx as 
	(SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent, MAX((vax.people_fully_vaccinated/death.population)*100) as max_vax
	FROM PortfolioProject..CovidDeaths as death
	JOIN PortfolioProject..CovidVaccinations as vax
		on death.location = vax.location
		and death.date = vax.date
	WHERE death.continent is not null
	GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
	)
SELECT location, population, MAX(max_vax) as FullVaxPercent, continent
FROM CTE_vaxx
GROUP BY location, continent, population
HAVING MAX(max_vax) > 46.92
ORDER by FullVaxPercent desc

-- Looking at countries ABOVE the world average (using a CTE) AND with a significant population (+10 million)
WITH CTE_Vaxx as 
	(SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent, MAX((vax.people_fully_vaccinated/death.population)*100) as max_vax
	FROM PortfolioProject..CovidDeaths as death
	JOIN PortfolioProject..CovidVaccinations as vax
		on death.location = vax.location
		and death.date = vax.date
	WHERE death.continent is not null
	GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
	)
SELECT location, population, MAX(max_vax) as FullVaxPercent, continent
FROM CTE_vaxx
WHERE population >10000000
GROUP BY location, continent, population
HAVING MAX(max_vax) > 46.92
ORDER by FullVaxPercent desc


-- Looking at the countries BELOW the world average

WITH CTE_Vaxx as 
	(SELECT death.continent, death.location, death.population, death.date, MAX(CONVERT(bigint, people_fully_vaccinated)) as FullVaxPop, (vax.people_fully_vaccinated/death.population)*100 as FullVaxPercent, MAX((vax.people_fully_vaccinated/death.population)*100) as max_vax
	FROM PortfolioProject..CovidDeaths as death
	JOIN PortfolioProject..CovidVaccinations as vax
		on death.location = vax.location
		and death.date = vax.date
	WHERE death.continent is not null
	GROUP BY death.continent, death.location, death.population, death.date, vax.people_fully_vaccinated
	)
SELECT location, population, MAX(max_vax) as FullVaxPercent, continent
FROM CTE_vaxx
GROUP BY location, continent, population
HAVING MAX(max_vax) < 46.92
ORDER by FullVaxPercent desc



--- HOSPITILIZATION QUERIES ---

-- Looking at highest hospitalization and ICU counts, alongside hospitalization rates (using a temp table)

DROP TABLE IF exists #HighestPercentPopulationHospitalized
CREATE TABLE #HighestPercentPopulationHospitalized
(
Location nvarchar(255),
Continent nvarchar(255),
Date datetime,
Population numeric,
total_cases numeric,
total_deaths numeric,
total_hosp_patients numeric,
total_icu_patients numeric,
people_fully_vaccinated numeric,
New_vaccinations numeric,
FullyVaxxedPercent numeric
)

INSERT INTO #HighestPercentPopulationHospitalized

SELECT death.location, death.continent, death.date, death.population, death.total_cases, death.total_deaths, (CAST(death.hosp_patients as bigint)) as total_hosp_patients, (CAST(death.icu_patients as bigint)) as total_icu_patients, vax.people_fully_vaccinated, (death.total_deaths/death.total_cases)*100 as DeathPercentage, (vax.people_fully_vaccinated/death.population)*100 as FullyVaxxedPercent
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vax
	on death.location = vax.location
	and death.date = vax.date
WHERE death.continent is not null AND death.hosp_patients is not null AND death.icu_patients is not null AND vax.people_fully_vaccinated is not null
GROUP BY death.location, death.continent, death.date, death.population, death.total_cases, death.total_deaths, death.hosp_patients, death.icu_patients, vax.people_fully_vaccinated

-- Query off of new temp table --

-- Looking at highest amount of people hospitalized per country 
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population
ORDER by HighestHospitilizationNumber desc


-- Looking at highest percent of people hospitalized per country (vs total population)
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population
ORDER by HighestPercentHospitalized desc


-- Looking at highest count of patients in ICU
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population
ORDER by HighestICUNumber desc


-- Looking at highest percent of people in ICU per country (vs total population)
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population
ORDER by HighestPercentICU desc


-- Looking at ICU vs those infected (not entire population)
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population, total_cases
ORDER by PercentPopInfectedICU desc


-- Looking at ICU rates vs those infected (not entire population) of a specific country
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU
FROM #HighestPercentPopulationHospitalized
WHERE location = 'Canada'
GROUP BY location, continent, population, total_cases
ORDER BY PercentPopInfectedICU desc


-- Looking at hospitilization rates vs those infected (not entire population)
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU, (MAX(total_hosp_patients)/MAX(total_cases))*100 as PercentPopInfectedHosp
FROM #HighestPercentPopulationHospitalized
WHERE continent is not null
GROUP BY location, continent, population, total_cases
ORDER BY PercentPopInfectedHosp desc

-- Looking at hospitilization rates vs those infected (not entire population) of a specific country
SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, (MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU, (MAX(total_hosp_patients)/MAX(total_cases))*100 as PercentPopInfectedHosp
FROM #HighestPercentPopulationHospitalized
WHERE location = 'Canada'
GROUP BY location, continent, population, total_cases
ORDER BY HighestHospitilizationNumber desc


-- Getting single country numbers w CTE - highest percent of infected population that was hospitalized

WITH CTE_HospICU as
	(SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, 
	(MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU, (MAX(total_hosp_patients)/MAX(total_cases))*100 as PercentPopInfectedHosp
	FROM #HighestPercentPopulationHospitalized
	WHERE continent is not null
	GROUP BY location, continent, population, total_cases
	)
SELECT location, continent, MAX(PercentPopInfectedHosp) as HighestPercentPopInfectedHosp
FROM CTE_HospICU
GROUP BY location, continent
ORDER BY HighestPercentPopInfectedHosp desc


-- Getting single country numbers w CTE - highest percent of infected population that was in ICU

WITH CTE_HospICU as
	(SELECT location, continent, population, MAX(total_hosp_patients) as HighestHospitilizationNumber, MAX(total_icu_patients) as HighestICUNumber, (MAX(total_hosp_patients)/population)*100 as HighestPercentHospitalized, 
	(MAX(total_icu_patients)/population)*100 as HighestPercentICU, (MAX(total_icu_patients)/MAX(total_cases))*100 as PercentPopInfectedICU, (MAX(total_hosp_patients)/MAX(total_cases))*100 as PercentPopInfectedHosp
	FROM #HighestPercentPopulationHospitalized
	WHERE continent is not null
	GROUP BY location, continent, population, total_cases
	)
SELECT location, continent, MAX(PercentPopInfectedICU) as HighestPercentPopInfectedICU
FROM CTE_HospICU
GROUP BY location, continent
ORDER BY HighestPercentPopInfectedICU desc



--- Other ---

-- Creating a view to easily access total global population, for calculating certain rates

CREATE VIEW TotalWorldPopulation as

SELECT SUM(population) OVER () as world_population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location, population

SELECT * FROM TotalWorldPopulation

DROP VIEW TotalWorldPopulation;
