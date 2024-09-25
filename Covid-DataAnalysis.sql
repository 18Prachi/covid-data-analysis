select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- breaking things down by location
-- Select Data

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs total Deaths
-- likelyhood of dying if you get covid in India
select location, date, total_cases, total_deaths,
case 
	when total_cases = 0 then 0 
	else (total_deaths/ total_cases) * 100
end as death_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Total Cases vs Population
-- percentage of population got covid

select location, date, total_cases, population,
case 
	when total_cases = 0 then 0 
	else (total_cases/ population) * 100
end as population_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- countries with highest infection rate compared to population

SELECT 
    location, 
    population, 
    MAX(total_cases) AS 'highest infection count',
    MAX(total_cases / NULLIF(population, 0)) * 100 AS infection_rate_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate_percentage desc;

-- countries with highest death_count per population

select location, max(total_deaths) as 'highest deaths count'
from CovidDeaths
where continent is null
group by location
order by 'highest deaths count' desc

-- breaking things down by continent

-- continents with the highest death count

select continent, max(total_deaths) as 'highest deaths count'
from CovidDeaths
where continent is not null
group by continent
order by 'highest deaths count' desc

-- GLOBAL NUMBERS

select sum(total_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
	SUM(new_deaths) / sum(nullif(new_cases,0)) * 100 as deathPercent
from CovidDeaths
where continent is not null
--group by date
order by 1,2

select location 
from CovidVaccinations

-- using cte
with pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as(
-- Total Population vs Total Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
	and dea.date = try_cast(vac.date as DATE)
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from pop_vs_vac

-- temp table

create table #PercentPopulationVaccinated
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
	and dea.date = try_cast(vac.date as DATE)
where dea.continent is not null
--order by 2,3
select *, (rolling_people_vaccinated/population)*100
from pop_vs_vac


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
	and dea.date = try_cast(vac.date as DATE)
where dea.continent is not null

select * from PercentPopulationVaccinated