-- Covid Deaths Dataset Analysis
Select *
From Covid19Database.dbo.CovidDeaths

-- Ordering the CovidDeaths dataset by country and date in ascending order 
Select *
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Order by 3,4

-- Select the key data for the analysis and order by location and date in ascending order:
Select location, date, total_cases, new_cases, total_deaths, population
From Covid19Database.dbo.CovidDeaths 
Where continent IS NOT NULL
Order by 1,2

-- Extracting Total Case vs Total Deaths and death percentage in a country
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as 'Death Percentage'
From Covid19Database.dbo.CovidDeaths 
Where continent IS NOT NULL
Order by 1,2

-- Extracting Total Case vs Total Deaths and death percentage in United States
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as 'Death Percentage'
From Covid19Database.dbo.CovidDeaths 
Where location like '%states%' and continent IS NOT NULL
Order by 2

-- Extracting Total Case vs Total Deaths and death percentage in United Kingdom
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as 'Death Percentage'
From Covid19Database.dbo.CovidDeaths 
Where location like '%kingdom%' and continent IS NOT NULL
Order by 2

-- Extracting Total Cases vs Population and Percentage of infected Population
Select location, date, total_cases, population, ((total_cases/population)*100) as 'Percentage Infected Population'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Order by 1,2

-- Extracting Total Cases vs Population and Percentage of infected Population in UK
Select location, date, total_cases, population, ((total_cases/population)*100) as 'Percentage Infected Population'
From Covid19Database.dbo.CovidDeaths
Where location like '%kingdom%' and continent IS NOT NULL
Order by 1,2

-- Extracting Countries with Highest Infection Rate compared to population
Select location,  population, MAX(total_cases) as 'Total Infection Count', MAX((total_cases/population)*100) as 'Percentage Infected Population'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location, population
Order by 'Percentage Infected Population' DESC

-- Extracting Countries with Highest Death Count 
Select location,  MAX(CAST(total_deaths as Int)) as 'Total Death Count'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location
Order by 'Total Death Count' DESC

-- Extracting Total Death Count of each Continent
Select location,  MAX(CAST(total_deaths as Int)) as 'Total Death Count'
From Covid19Database.dbo.CovidDeaths
Where continent IS NULL
Group by location
Order by 'Total Death Count' DESC

-- Extracting the Global Numbers: Total Cases, Total Deaths and the Death Percentage group by Date:
Select date,  SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths as Int)) as 'Total Deaths',
(SUM(CAST(new_deaths as Int))/SUM(new_cases))*100 as 'Death Percantage'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Group by date
Order by 1,2

-- Extracting the Global Numbers: Total Cases, Total Deaths and the Death Percentage:
Select SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths as Int)) as 'Total Deaths',
(SUM(CAST(new_deaths as Int))/SUM(new_cases))*100 as 'Death Percantage'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Order by 1,2


-- Covid Vaccination Dataset Analysis

Select *
From Covid19Database.dbo.CovidVaccinations

--Combining the two datsets using Join:

Select *
From Covid19Database.dbo.CovidDeaths as D
Join Covid19Database.dbo.CovidVaccinations as V
	on D.location = V.location
	and D.date = V.date


--Looking at Total Population vs Vaccination

Select D.continent, D.location, D.date, D.population, V.new_vaccinations 
From Covid19Database.dbo.CovidDeaths as D
Join Covid19Database.dbo.CovidVaccinations as V
	on D.location = V.location
	and D.date = V.date
Where D.continent IS NOT NULL
order by 2,3

--Looking at Total Population vs Vaccination using Common Table Expression (CTE)

With PopvsVacc (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations as BigINT)) OVER (Partition by D.location Order by D.location, D.date) as Rolling_People_Vaccinated
From Covid19Database.dbo.CovidDeaths as D
Join Covid19Database.dbo.CovidVaccinations as V
	on D.location = V.location
	and D.date = V.date
Where D.continent IS NOT NULL
)

Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVacc

--CREATING TEMP TABLE

Drop TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations as BigINT)) OVER (Partition by D.location Order by D.location, D.date) as Rolling_People_Vaccinated
From Covid19Database.dbo.CovidDeaths as D
Inner Join Covid19Database.dbo.CovidVaccinations as V
	on D.location = V.location
	and D.date = V.date


Select *, (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations:

Create VIEW PercentPopulationVaccinated as

Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations as BigINT)) OVER (Partition by D.location Order by D.location, D.date) as Rolling_People_Vaccinated
From Covid19Database.dbo.CovidDeaths as D
Join Covid19Database.dbo.CovidVaccinations as V
	on D.location = V.location
	and D.date = V.date
Where D.continent IS NOT NULL

Select *
From PercentPopulationVaccinated



