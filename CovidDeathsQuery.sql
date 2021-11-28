-- Continents are also included in location
-- Continents in 'location' have a NULL value in continent
-- Need to use "null" where statements om continents to swap between using countries/continents
Select *
From PortfolioCovid..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioCovid..CovidVaccinations$
--order by 3,4

-- Selecting Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioCovid..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Likelyhood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases) *100 as DeathPercentage
From PortfolioCovid..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- What percent of population contracted COVID
Select Location, date, Population, total_cases, (total_cases/population) *100 as PopulationPercentage
From PortfolioCovid..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PopulationInfectedPercentage
From PortfolioCovid..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location, Population
order by PopulationInfectedPercentage desc


-- Countries with Highest death count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioCovid..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc

-- By Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioCovid..CovidDeaths
Where continent is null
--Where location like '%states%'
Group by location
order by TotalDeathCount desc


-- Global Numbers
Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioCovid..CovidDeaths
Where continent is not null
group by date
order by 1,2

-- World Total Cases
Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioCovid..CovidDeaths
Where continent is not null
order by 1,2

-- Total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.Location order by dea.location, dea.Date) as RollingVaccinated
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With Popvsvac (Continent, location, Date, Population, new_vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.Location order by dea.location, dea.Date) as RollingVaccinated
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * ,(RollingVaccinated/Population)*100
From Popvsvac

-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.Location order by dea.location, dea.Date) as RollingVaccinated
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * ,(RollingVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create View for later visualizations
USE PortfolioCovid;
GO
Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.Location order by dea.location, dea.Date) as RollingVaccinated
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

