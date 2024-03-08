Select *
from PortfolioProject.dbo.CovidDeaths
Order by 3,4

Select *
from PortfolioProject.dbo.CovidVaccinations
Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Order by 1,2


--Loking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_Deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location Like '%cco%'
Order by 1,2

--Looking at Total Cases vs Population 
--Shows what percentage of population got Covid

Select location, date, total_cases, Population, (total_cases/population)*100 as GotCovPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, max(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as GotCovPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
Group by location, Population
Order by GotCovPercentage desc


--Showing countries with Highest deat count per population

Select location,  max(cast(total_Deaths as int))as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
where continent is not null 
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--continent is not null
Select location,  max(cast(total_Deaths as int))as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
where continent is not null 
Group by location
Order by TotalDeathCount desc

---------continent is null

Select location,  max(cast(total_Deaths as int))as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
where continent is null 
Group by location
Order by TotalDeathCount desc

------Group by continent

Select continent,  max(cast(total_Deaths as int))as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
where continent is not null 
Group by continent
Order by TotalDeathCount desc

--shwing continents with the highest death count per population

Select continent,  max(cast(total_Deaths as int))as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location Like '%cco%'
where continent is not null 
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS
--by date
Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths , (Sum(cast(New_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY date
Order by 1,2

-- the wole word

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths , (Sum(cast(New_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
--GROUP BY date
Order by 1,2


--Loking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as a
FROM PopvsVac

---- TEM TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as a
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

SELECT *
From PercentPopulationVaccinated