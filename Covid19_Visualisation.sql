-- Covid-19 Data Visualisation

-- Extracting the Global Numbers: Total Cases, Total Deaths and the Death Percentage:
Select SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths as BigInt)) as 'Total Deaths',
(SUM(CAST(new_deaths as BigInt))/SUM(new_cases))*100 as 'Death Percantage'
From Covid19Database.dbo.CovidDeaths
Where continent IS NOT NULL
Order by 1,2



-- Total Death Count by Continents

Select location,  MAX(CAST(total_deaths as Int)) as 'Total Death Count'
From Covid19Database.dbo.CovidDeaths
Where continent IS NULL 
and location not in ('World', 'High income','Upper middle income', 'Lower middle income','Low income','European Union', 'International')
Group by location
Order by 'Total Death Count' DESC

-- Extracting Countries with Highest Infection Rate compared to population
Select location,  population, MAX(total_cases) as 'Total Infection Count', MAX((total_cases/population)*100) as 'Percentage Infected Population'
From Covid19Database.dbo.CovidDeaths
Group by location, population
Order by 'Percentage Infected Population' DESC


-- Extracting Countries with Highest Infection Rate compared to population group by date

Select location,  population, date, MAX(total_cases) as 'Total Infection Count', MAX((total_cases/population)*100) as 'Percentage Infected Population'
From Covid19Database.dbo.CovidDeaths
Group by location, population, date
Order by 'Percentage Infected Population' DESC

