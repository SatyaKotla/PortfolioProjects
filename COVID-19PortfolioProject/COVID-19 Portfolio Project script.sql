Select * from PortfolioProject.dbo.CovidDeaths$
where continent is not NULL
order by 3,4


--Select * from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject.dbo.CovidDeaths$
where continent is not NULL
order by 1,2

--looking at total cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not NULL
order by 1,2

--Looking at Total Cases vs Population

Select Location, date, total_cases,Population,(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not NULL
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not NULL
Group by Location,Population
order by PercentPopulationInfected desc


--showing the countries with the highest death count per population
Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not NULL 
Group by Location,Population
order by TotalDeathCount desc


--Let's Break things down by Continent

--Select location,Max(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject.dbo.CovidDeaths$
----where location like '%states%'
--where continent is NULL 
--Group by location
--order by TotalDeathCount desc

--showing the continents with highest death count per population
Select continent,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not NULL 
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where continent is not NULL
Group by date
order by 1,2


--Vaccinations

Select * from PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date

--Looking at Total Population vs Vaccination 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not NULL
order by 1,2,3

--USE CTE
With PopVsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 from PopVsVac


--Temp Table

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
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not NULL
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccianted as 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3