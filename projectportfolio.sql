select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--where continent is not null
--order by 3,4


select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Caes vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

-- looking at Total Cases v Population
-- Shows what percentage of population got covid

select Location,date,population,total_cases, (total_cases/population) *100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%india%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
group by Location,population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
-- group by date
order by 1,2


-- Lookind at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
-- where dea.continent is not null
-- order by 2,3
select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for latervisualization

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations 
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
-- order by 2,3

select * from
PercentPopulationVaccinated

