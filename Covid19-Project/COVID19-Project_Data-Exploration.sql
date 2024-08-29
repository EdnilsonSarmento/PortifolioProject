/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

By Ednilson Sarmento

*/


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortifolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths
Where total_cases != 0 AND location like '%Moz%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got covid

Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentagePopulationInfected
From PortifolioProject..CovidDeaths
Where location like '%Moz%'
Order by 1,2

-- Looking at countries with highest infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
From PortifolioProject..CovidDeaths
Group by Location, Population
Order by PercentagePopulationInfected desc

-- Showing the countries with Highest Death count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortifolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Let's break things down by continet

Select continent, MAX(total_deaths) as TotalDeathCount
From PortifolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_case, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths
Where continent is not null AND new_cases !=0
Group by date
order by 1,2

-- Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccine

 Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
 From PortifolioProject..CovidDeaths dea
 Join PortifolioProject..CovidVaccinations vac
 On dea.location = vac.location And dea.date = vac.date
 Where dea.continent is not null
 order by 2,3

 -- Using CTE to perform calculation on Partition by in previous query
 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 From PortifolioProject..CovidDeaths dea
 Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 From PortifolioProject..CovidDeaths dea
 Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortifolioProject..CovidDeaths dea
 Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated
