select *
from CovidDeaths
where continent is not null
order by 3,4

select *
from CovidVaccinations
order by 3,4


-- select Data that We will be using

select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location,date, total_cases, population, (total_cases/population)*100 as InfectionRate
from CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking at counties with highest infection rates

select location, max(total_cases) as Cases, population, max((total_cases/population))*100 as InfectionRate
from CovidDeaths
where continent is not null
group by location, population
order by InfectionRate desc

-- This is showing countries with highest deathrate

select location, max(cast(total_deaths as int)) as Deathcount
from CovidDeaths
where continent is not null
group by location
order by Deathcount desc

-- By Continent


SELECT continent, SUM(CAST(total_deaths AS INT)) AS Deathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Deathcount DESC;

-- Global numbers by date

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1


-- Total numbers globally

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
order by 1

-- Looking at total population vs Vaccinations
-- Use CTE

with PopvsVax (continent, location, date, population, new_vaccinations,TotalVacinated)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as TotalVacinated
from CovidDeaths as D
join CovidVaccinations as V
	on D.location=v.location and d.date=v.date
where d.continent is not null
--order by 2,3
)

select *, (TotalVacinated/population)*100
from PopvsVax


-- Temp Table
drop table if exists #PercentPopulationVax
create table #PercentPopulationVax(
Continent varchar(50), 
Location varchar(50), 
date datetime,
Population numeric,
NewVaccinations numeric,
TotalVacinated numeric)


insert into #PercentPopulationVax
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as TotalVacinated
from CovidDeaths as D
join CovidVaccinations as V
	on D.location=v.location and d.date=v.date
where d.continent is not null
--order by 2,3


select *, (TotalVacinated/population)*100
from #PercentPopulationVax
order by 2,3

--Creating View
create view PercentPopulationVax as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as TotalVacinated
from CovidDeaths as D
join CovidVaccinations as V
	on D.location=v.location and d.date=v.date
where d.continent is not null
--order by 2,3