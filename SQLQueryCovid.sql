select * from portfolioProject..coviddeath where continent is not null;

select location, date,population, total_cases, (total_cases/population) as deathpercentage
from portfolioProject..coviddeath
where continent is not null
order by 1,2

select location,population, max(total_cases) as highestInfectionCount, max(total_cases/population)*100 as percentPopulationInfected
from portfolioProject..coviddeath
where continent is not null
group by location,population
order by 4 desc

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..coviddeath
where continent is not null
group by location
order by 2 desc

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..coviddeath
where continent is not null
group by continent
order by TotalDeathsCount desc

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..coviddeath
where continent is null
group by location
order by TotalDeathsCount desc

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..coviddeath
where continent is null
and location not in ('High income','Upper middle income','Lower middle income','Low income')
group by location
order by TotalDeathsCount desc

-- global numbers
select location, date, total_deaths, total_cases, (total_deaths/total_cases) as deathpercentage
from portfolioProject..coviddeath
where continent is not null
--where location like '%state%'
order by 1,2

select date, sum(new_deaths) as total_deaths, sum(new_cases) as total_cases,  
(sum(new_deaths)/(sum(new_cases)+1)) as deathpercentage
from portfolioProject..coviddeath
where continent is not null
--where location like '%state%'
group by date
order by 1

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as countryVaccinationsCount
from portfolioProject..coviddeath dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopvsVac(continent, location,date, population,new_vaccinations,countryVaccinationsCount)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as countryVaccinationsCount
from portfolioProject..coviddeath dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (countryVaccinationsCount/population)*100 from PopvsVac

--temp table

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
countryVaccinationsCount numeric)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as countryVaccinationsCount
from portfolioProject..coviddeath dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (countryVaccinationsCount/population)*100 from #percentPopulationVaccinated

--creating view

CREATE VIEW populationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as countryVaccinationsCount
from portfolioProject..coviddeath dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;
--order by 2,3

select * from populationVaccinated


select sum(new_cases) as 