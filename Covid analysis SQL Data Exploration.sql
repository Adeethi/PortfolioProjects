 --select * from PortfolioProject.dbo.covidDeath
--order by 3,4

-- select Data that's useful
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.covidDeath
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from PortfolioProject.dbo.covidDeath
where location = 'India'
order by 1,2

-- Looking at Total cases vs population
--Shows what percentage of people got covid
select location, date, population, total_cases, (total_cases/population) * 100 as affected_percentage
from PortfolioProject.dbo.covidDeath
where location = 'India'
order by 1,2

-- Looking at countries with highest infection rate compared to Population
select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population)) * 100 as affected_percentage
from PortfolioProject.dbo.covidDeath
group by location, population
order by affected_percentage desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as highestDeathCount
from PortfolioProject.dbo.covidDeath
where continent is not null
group by location
order by highestDeathCount desc

-- by continent

--Showing continents with the highest death count per population
select location, max(cast(total_deaths as int)) as highestDeathCount
from PortfolioProject.dbo.covidDeath
where continent is null
group by location
order by highestDeathCount desc 

-- Global numbers ( you can select date to display datewise)
select  sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as death_percentage
from PortfolioProject.dbo.covidDeath
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination and Percentage of people vaccinated

--USE CTE
With PopvsVac(Continent, Location, Date, Population, NewVaccine, RollingPeopleVaccinated)
as 
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by death.location order by death.location, death.date) as 
RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
from PortfolioProject..covidDeath death
join PortfolioProject..covidVaccination vac
	on death.location= vac.location and death.date=vac.date
where death.continent is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/population)* 100
from PopvsVac
-- we can also create temporary table and then perform calculation
--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
NewVaccine numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by death.location order by death.location, death.date) as 
RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
from PortfolioProject..covidDeath death
join PortfolioProject..covidVaccination vac
	on death.location= vac.location and death.date=vac.date
where death.continent is not null

select *, (RollingPeopleVaccinated/population)* 100
from #PercentPopulationVaccinated

--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) Over (Partition by death.location order by death.location, death.date) as 
RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
from PortfolioProject..covidDeath death
join PortfolioProject..covidVaccination vac
	on death.location= vac.location and death.date=vac.date
where death.continent is not null
)
