 -- drop database if exists TEMI_PortfolioProject;
 -- CREATE database TEMI_PortfolioProject ;

select * from coviddeaths  order by 2; 
select continent from coviddeaths group by continent;
select * from covidvacccinations order by 3, 4;
-- Cleaning up, updating and deleting data
UPDATE coviddeaths set continent = 'South America' where location = 'South America' ;
UPDATE coviddeaths set continent = 'European Union' where location = 'European Union' ;
select * from coviddeaths where location = 'High income' ;
delete from coviddeaths where location = 'High income';
delete from coviddeaths where location = 'Low income';


select iso_code, continent, location from coviddeaths group by iso_code, continent, location ;

select distinct location from coviddeaths;
select distinct location from covidvacccinations;
-- selecting data to be used
select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1, 2;

-- cases vs total deaths with  % likelihood of death from covid in United States (9/9/22  0.53%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from coviddeaths where location like "%States%"  order by 1, 2;

-- Cases vs Population - shows % of population with Covid (9/9/22 22.9% of population has Covid)
select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage from coviddeaths where location like "%States%"  order by 1, 2;

-- Countries with Highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentage from coviddeaths group by location, 
population order by populationPercentage desc;

-- courntries with highest death count per population (United States- Highest wow wow)
select location, MAX(total_deaths) as TotalDeathCount from coviddeaths group by location order by TotalDeathCount desc;
-- Continents with highest death count 
select continent, MAX(total_deaths) as TotalDeathCount from coviddeaths  group by continent order by MAX(total_deaths) desc;
-- global percentages of death compared to cases by date
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100  as DeathPercentage from coviddeaths group by date order by 1, 2;
-- global percentages of death compared to cases (date removed)
select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100  as DeathPercentage from coviddeaths  order by 1, 2;
-- Join both tables- coviddeath and covidvaccines
select *
from coviddeaths cdea
join covidvacccinations cvac
on cdea.location = cvac.location and cdea.date = cvac.date;

-- Total Population vs vaccinations -Joins
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
 from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date order by 2, 3;

-- Total Population vs vaccinations -Joins/partition
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date order by 2, 3;

-- CTE table to show percentages of vaccinations per population with partition roll up
With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, sumRollVaccinations) as
(select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date )
select *, (sumRollVaccinations/Population) * 100 from PopVsVac;

select * from coviddeaths;