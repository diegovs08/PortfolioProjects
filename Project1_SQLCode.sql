-- Complete CovidDeaths Table
Select *
From ProjectSQL1..CovidDeaths
Order by 3,4

-- Complete CovidVaccinations Table
Select *
From ProjectSQL1..CovidVaccinations
Order by 3, 4

--Peru vaccinations' situation
Select location, date, new_vaccinations, total_vaccinations, people_fully_vaccinated, people_vaccinated
From ProjectSQL1..CovidVaccinations
where Location = 'Peru'
Order by 1, 2

-- Total cases, New cases, Total deaths and Population
Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectSQL1..CovidDeaths
Order by 1, 2

--Percentage of population that die because of covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage, population
From ProjectSQL1..CovidDeaths
Where Location = 'Australia'
Order by 1, 2

--Percentage of population infected per country day by day
Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From ProjectSQL1..CovidDeaths
Where Location = 'Brunei'
Order by 1, 2

--Countries with the percentage highest population infected
Select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as CasesPercentage
From ProjectSQL1..CovidDeaths
where continent is not null
Group by Location, Population
Order by 4 DESC

--Countries with the percentage highest population dead
Select Location, max(cast(total_deaths as int)) as TotalDeaths, population, max((total_deaths/population))*100 as DeathPercentage
From ProjectSQL1..CovidDeaths
where continent is not null
Group by Location, population
Order by 4 DESC

--Continents with the highest population dead
With ContDeaths(continent, location, TotalDeaths, population)
as (Select continent, location, max(cast(total_deaths as int)) as TotalDeaths, population
From ProjectSQL1..CovidDeaths
where continent is not null
Group by continent, location, population
)

Select top 6 continent, sum(TotalDeaths) as ContinentDeaths
from ContDeaths
Group by continent
order by 2 desc


--Cases and percentage of deaths day by day
Select date, SUM(new_cases) as NewCasestot, Sum(total_cases) as TotalCases , sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageDeathsPerDay
From ProjectSQL1..CovidDeaths
where continent is not null
Group by date
Having sum(new_cases) <> 0
order by 1

--Vaccinations counter
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated, vac.total_vaccinations as VaccinationsApplied
From ProjectSQL1..CovidDeaths dea
Join ProjectSQL1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinationsApplied
From ProjectSQL1..CovidDeaths dea
Join ProjectSQL1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (PeopleVaccinated/Population)*100 as PercentageOfVaccinations
from PopvsVac

--TEMP TABLE

Drop table if exists #PercPoppVac
Create table #PercPoppVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercPoppVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinationsApplied
From ProjectSQL1..CovidDeaths dea
Join ProjectSQL1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (PeopleVaccinated/Population)*100 as VaccinationsApplied
from #PercPoppVac