SELECT *
FROM PortfolioProject .. CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject .. CovidVaccinations$
--ORDER BY 3,4

--SELECT data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject .. CovidDeaths$
order by 1,2

-- Looking at total cases v/s total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths$
where location like '%ndia'
order by 1,2

-- Looking at total cses v/s population

select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationEffected
from PortfolioProject .. CovidDeaths$
where location = 'India'
order by 1,2

-- Looking at countries having highest infection rates compared to population
select location,population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationEffected
from PortfolioProject .. CovidDeaths$
Group by location, population
order by PercentPopulationEffected desc

select location, Max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject .. CovidDeaths$
Where continent is not null
Group by location
order by Total_death_count desc

-- LET'S BREAK THING DOWN BY CONTINENT

select continent,Max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent   
order by Total_death_count desc

--GLOBAL NUMBERS
SELECT  SUM(new_cases) AS TOTAL_CASES, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as 
Death_percentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--LOoking at total population v/s Vaccinations
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null
  order by 2,3
  

 --Use CTE
  with PopvsVac(continent, location,date, population,new_vaccinations,RollingPeopleVaccinated   )
  as
  ( 
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null
 -- order by 2,3
 )

select *,(RollingPeopleVaccinated/population)*100
 from PopvsVac


  --Temp table

  Drop table if exists #PercentagePopulationVaccinated
  Create table #PercentagePopulationVaccinated(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  Insert into #PercentagePopulationVaccinated
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
 from #PercentagePopulationVaccinated

 --Creating view to store data for later visualizations
 create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null
 -- order by 2,3

 Select *
 from PercentagePopulationVaccinated