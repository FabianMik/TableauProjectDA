

/*
Queries for Tableau Project
Dataset: https://ourworldindata.org/covid-deaths
*/


select *
from PorftolioProject..CovidDeaths
where location = 'Asia'
order by 3,4


--select *
--from PorftolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PorftolioProject..CovidDeaths
order by 1,2


--1 Visualization
-- looking at total cases vs total deaths
-- P(dying | covid)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PorftolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--2 Visualization
-- Eliminating redundancies

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PorftolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3 Visualization
-- countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PorftolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--4 Visualization
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PorftolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- countries with highest death count per capita
select location, population, max(cast(total_deaths as float)) as TotalDeathCount, max(total_deaths/population*100) as DeathPerCapitaPercentage
from PorftolioProject..CovidDeaths
group by location, population
order by DeathPerCapitaPercentage desc

-- countries with highest death toll
select location, max(cast(total_deaths as float)) as TotalDeathCount
from PorftolioProject..CovidDeaths
where continent not like ''
group by location
order by TotalDeathCount desc

-- global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorftolioProject..CovidDeaths
where continent not like ''
group by date
order by 1,2 desc

-- looking at total population vs vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorftolioProject..CovidDeaths dea
Join PorftolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac