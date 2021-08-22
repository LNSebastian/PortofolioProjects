
select *
from covid19.deaths
order by 3, 4

--select *
--from covid19.vaccinations
--order by 3, 4


--select the data that will be used

select location, date, total_cases, new_cases, total_deaths, population
from covid19.deaths
order by 1, 2


--Total cases vs Total deaths
-- shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from covid19.deaths 
--where location like 'Romania'
order by 1, 2


--Total cases vs Population
--shows what percentage of population got covid

select location, date, population,total_cases, total_deaths, (total_cases/population)*100 as infection_percentage
from covid19.deaths
where location = 'Romania'
order by 1,2


--Countrys with highest infection rate compare to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as infection_percentage
from covid19.deaths 
--where location = 'Romania'
group by location, population
order by infection_percentage desc nulls last


--Countries with highest death count per population

select location, max(total_deaths) as total_deaths_count
from covid19.deaths 
where continent is not null
group by location
order by total_deaths_count desc nulls last


--Continents with highest death count per population

select continent, max(total_deaths) as total_deaths_count
from covid19.deaths
where continent is not null 
group by continent
order by total_deaths_count desc nulls last


--Global numbers

select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid19.deaths 
where continent is not null 
--group by date
order by 1,2


--Total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from covid19.deaths d
join covid19.vaccinations v 
	on d.location = v.location
    and d.date = v.date
where d.continent is not null 
--and d.location = 'Romania'
order by 2,3


--use common table expressions

with pop_vs_vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from covid19.deaths d
join covid19.vaccinations v 
	on d.location = v.location
    and d.date = v.date
where d.continent is not null 
--and d.location = 'Romania'
order by 2,3
)
select *,(rolling_people_vaccinated/population)*100 as percent_population_vaccinated
from pop_vs_vac



--create view to store data for later visualization

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from covid19.deaths d
join covid19.vaccinations v 
	on d.location = v.location
    and d.date = v.date
where d.continent is not null 
--and d.location = 'Romania'
order by 2,3


create view ContinentsDeaths as
select continent, max(total_deaths) as total_deaths_count
from covid19.deaths
where continent is not null 
group by continent
order by total_deaths_count desc nulls last