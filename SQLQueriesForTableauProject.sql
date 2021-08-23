

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

-- looking at total cases vs total deaths
-- P(dying | covid)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorftolioProject..CovidDeaths
where location like'%states%'
order by 1,2

-- what percentage of population has/had covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PorftolioProject..CovidDeaths
where location = 'Germany'
order by 1,2

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as TotalCases, max(total_cases/population*100) as InfectionRatePercentage
from PorftolioProject..CovidDeaths
group by location, population
order by InfectionRatePercentage desc

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