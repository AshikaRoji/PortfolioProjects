/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations$
order by 3,4

--Lets select the data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 1,2

--Looking at total cases vs total deaths 
--shows likehood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%' 
AND continent is not null
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%india%'
order by 1,2

--Looking at what country has highest infection rate

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths$
group by Location, population
order by CovidPercentage desc


--Showing countries with Highest Death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by Location
order by TotalDeathCount desc

--Lets Break this down by continent
 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by continent
order by TotalDeathCount desc --this query doesnt include all the countries data in for eg Northamerica is showing only US data alone excludiong Canada

--corrected Query

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
group by location
order by TotalDeathCount desc

--Global Numbers

--Death Percentage group by date

SELECT Date, sum(new_cases) as Total_Cases , sum(cast (new_deaths as int)) as  Total_Deaths, 
(sum(cast (new_deaths as int))/sum(new_cases))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by date
order by 1,2

--Death Percentage in the world

SELECT sum(new_cases) as Total_Cases , sum(cast (new_deaths as int)) as  Total_Deaths, 
(sum(cast (new_deaths as int))/sum(new_cases))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--group by date
order by 1,2

--Joining Tables 
--Looking at Total_Population Vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--we cannot use alias for calculation so we use CTE ,(RollingPeopleVaccinated /dea.population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3

--USING CTE 

WITH PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--we cannot use alias for calculation so we use CTE ,(RollingPeopleVaccinated /dea.population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
--	ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated /population)*100
FROM PopvsVac 

--USING TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric ,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--we cannot use alias for calculation so we use CTE/temp table ,(RollingPeopleVaccinated /dea.population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--  WHERE dea.continent is not null
--	ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/population)*100 AS PercentageRollingPeopleVaccinated
FROM #PercentPopulationVaccinated

--Creating VIEW to store data foor later visualisation

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--we cannot use alias for calculation so we use CTE/temp table ,(RollingPeopleVaccinated /dea.population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--	ORDER BY 2,3

select *
from PercentPopulationVaccinated

