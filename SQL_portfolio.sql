--select*
--from Portfolio_Project.dbo.CovidDeaths
--where location = 'Asia'


-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,5

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, 
(total_deaths/nullif(total_cases,0))* 100
from CovidDeaths
where location = 'United States'
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of the population got Covid

select location, date, population, total_cases, 
(total_cases/population)* 100 Percent_Population_Infected
from CovidDeaths
order by date asc

-- Looking at countries with Highest Infection Rate compared to Population 

select location, population, max(total_cases) as Highest_Infection_Count,
max(total_cases/nullif(population,0))* 100 Percent_Population_Infected
from CovidDeaths
group by location, population
order by Percent_Population_Infected desc

--Countries with Highest Death Count per Population

select location,  max(total_deaths) as Total_Death_Count
from CovidDeaths
where continent is not NULL
group by location
order by Total_Death_Count desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

select location,  max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not NULL
group by location
order by Total_Death_Count desc

--Global Numbers

select sum(total_cases) AllTotal_Cases, sum(new_cases) AllNew_Cases,
sum(new_deaths)/sum(new_cases)*100 Global_DeathPercentage
from CovidDeaths
where continent is not NULL
order by 1,2

select avg(total_cases) AvgCases_per_Day, avg(new_cases) AvgNewCases_per_Day,
sum(new_deaths)/sum(new_cases)*100 Global_DeathPercentage
from CovidDeaths
where continent is not NULL
order by 1,2

--Looking at Total Population vs Vaccination, Part 1

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
VaccinationCount_of_Country
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Looking at Total Population vs Vaccination, Part 2

with CTE_CovidVaccines (Continent, Location, Date, Population, New_Vaccinations, VaccinationCount_of_Country)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
VaccinationCount_of_Country
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not NULL)

select*, (VaccinationCount_of_Country/nullif(Population,0))*100 PercentofPop_Vaccinated
from CTE_CovidVaccines

--Looking at Total Population vs Vaccination, with TempTable 

drop table if exists #vaccination_per_pop
create table #vaccination_per_pop
(Continent varchar(50),
Location varchar(100),
Date varchar (100),
Population float,
New_Vaccinations float,
VaccinationCount_of_Country float)

insert into #vaccination_per_pop
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
VaccinationCount_of_Country
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not NULL
order by 2,3

select*, (VaccinationCount_of_Country/nullif(Population,0))*100 PercentofPop_Vaccinated
from #vaccination_per_pop

--Creating View to store data for later visualizations
create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
VaccinationCount_of_Country
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

--select*
--from CovidDeaths
--order by date

--alter table CovidDeaths
--alter column total_cases float


--update CovidDeaths
--set total_cases = 0
--where total_cases  is NULL

--alter table CovidDeaths
--alter column DeathPercentage int



