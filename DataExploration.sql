Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
and location = 'Canada'
Order by 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
and location = 'Canada'
Order by 1,2 

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by location, population 
Order by PercentPopulationInfected desc

-- Looking at countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by location 
Order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Looking at continents with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null 
Group by location 
Order by TotalDeathCount desc

-- GLOBAL NUMBERS
--Select date, 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Group by date 
Order by 1,2

--Looking at total population VS vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RunningVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RunningVaccinationCount/population)*100 as RunningVaccinationPercentage
From PopVsVac
Order by 2,3

-- Use Temp Table
DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (RunningVaccinationCount/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationCount
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

