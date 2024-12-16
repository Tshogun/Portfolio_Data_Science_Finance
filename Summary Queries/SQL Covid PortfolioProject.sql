Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Canada%'
Order by 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid in Canada
Select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Marino%'
Order by 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((CONVERT(float, total_cases)) / NULLIF(population, 0))*100 as PercentPopulationInfection
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population
Order by PercentPopulationInfection desc

-- Showing countries with highest dead count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global Numbers
Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeath
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2


-- Showing Death percentage in the world in different days
Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
    case
        when SUM(new_cases) = 0 and SUM(new_deaths) <> 0 then NULL
		when SUM(new_cases) = 0 and SUM(new_deaths) = 0 then 0
        else SUM(new_deaths) * 100.0 / SUM(new_cases)
    end as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Group by date
Order by date


-- Showing Death percentage in the world
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
    case
        when SUM(new_cases) = 0 and SUM(new_deaths) <> 0 then NULL
		when SUM(new_cases) = 0 and SUM(new_deaths) = 0 then 0
        else SUM(new_deaths) * 100.0 / SUM(new_cases)
    end as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent IS NOT NULL


-- Join two tables
Select *
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3


-- Looking at Total Population vs Vaccination in Canada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
and dea.location like '%Canada%'
Order by 2,3


-- Looking at Cummulative vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumVaccination
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3




-- Looking at Cummulative vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumVaccination
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3


-- Looking at Cummulative vaccination over population per day (Use CTE)
With PopvsVac (continent, location, date, population, new_vaccination, CumVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumVaccination
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
)
Select *, (CumVaccination/population)*100 as CumVaccinePopulation
From PopvsVac


-- Looking at Cummulative vaccination over population per day (Use TEMP TABLE)
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumVaccination
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (CumVaccination/population)*100 as CumVaccinePopulation
From #PercentPopulationVaccinated



-- Creating view to store data for visualization (should execute in PortfolioProject database)

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumVaccination
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL

Select *
From PercentPopulationVaccinated