


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location, date



---Looking at Total Cases vs Total Deaths
---- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Canada%'
order by location, date



select 
date, population, total_cases, total_deaths
from CovidDeaths

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From CovidDeaths
Where continent is not null 
order by location, date


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by location, date


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%canada%'
and continent is not null 
order by location, date


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
---Where location like '%canada%'
order by location, date


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
---Where location like '%canada%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%Canada%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%canada%'
Where continent is null 
Group by location
order by TotalDeathCount desc


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount from
CovidDeaths
--Where location like '%canada%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%canada%'
where continent is not null 
--Group By date



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by location, date



Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations
, SUM(cast(vc.new_vaccinations as bigint)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null 
order by location, date

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations
, SUM(CONVERT(bigint,vc.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null 
--order by location, date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations
, SUM(CONVERT(bigint,vc.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
--where dea.continent is not null 
--order by location, date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations
, SUM(CONVERT(bigint,vc.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null 
