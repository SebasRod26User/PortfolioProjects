use PortfolioProject

select *
FROM PortfolioProject..CovidDeaths
order by 3,4;

select *
FROM PortfolioProject..CovidVaccinations
order by 3,4;

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2;

-- Looking ad Total Cases vs Total Deaths

--Percentage of deaths over infected
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like 'Costa Rica'
order by 1,2

--Percentaje of infected people
SELECT Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS InfectedPercentage
from PortfolioProject..covidDeaths
where location like 'Costa Rica'
order by 1,2

--Countries with highest infection compared to population

SELECT Location, population, MAX(total_cases) as HighestInfected, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS InfectedPercentage
from PortfolioProject..covidDeaths
--where location like 'Costa Rica'
group by location, population
order by InfectedPercentage desc

--Showing Countries with Highest Death Count per Population

SELECT Location, population, MAX(total_deaths) as HighestDeaths, MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS InfectedPercentage
from PortfolioProject..covidDeaths
--where location like 'Costa Rica'
Where continent  != '' --Removes where Continent is empty to show only countries
group by location, population
order by HighestDeaths desc

--Showing max deaths per continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..covidDeaths
where continent != ''
group by continent
order by TotalDeathCount desc

--Looking at Total Population vs Vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
FROM PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
Where deaths.continent  != '' 
order by 2,3

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
SUM(vacs.new_vaccinations) OVER (Partition by deaths.location, deaths.Date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
Where deaths.continent  != '' 
order by 2,3


--Using CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
SUM(vacs.new_vaccinations) OVER (Partition by deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
Where deaths.continent  != '' and deaths.location != 'International' and deaths.location != 'Northern Cyprus'
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
SUM(vacs.new_vaccinations) OVER (Partition by deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
Where deaths.continent  != '' and deaths.location != 'International' and deaths.location != 'Northern Cyprus'

Select *
From PercentPopulationVaccinated