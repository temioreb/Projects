/* Covid 19 Data
Used Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Creating View, Converting Data types
*/
 -- CREATE database TEMI_PortfolioProject ;
desc covidvacccinations;
desc coviddeaths;
select * from coviddeaths  order by 2; 
select continent from coviddeaths group by continent;
select * from covidvacccinations order by 3, 4;

-- Cleaning up, removing duplicates
alter table covidvacccinations modify column total_tests int;
delete from coviddeaths where continent = '';
delete from covidvacccinations where continent = '';
create temporary table temp
select distinct * from coviddeaths;
SELECT * FROM temp;
Truncate table coviddeaths;
-- delete from coviddeaths;
select * from coviddeaths;
insert into coviddeaths select * from temp ;
select * from coviddeaths;        
select * from covidvacccinations;
select distinct * from covidvacccinations ;
select * from temp;
truncate table temp;
select * from temp;
create temporary table temp1
select distinct * from covidvacccinations;
select * from temp1;
truncate table covidvacccinations;
select * from covidvacccinations;
insert into covidvacccinations select * from temp1 ;
select * from covidvacccinations;


-- selecting data to be used
select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1, 2;

-- cases vs total deaths with  % likelihood of death from covid in United States (9/9/22  0.53%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from coviddeaths where location like "%States%"  order by 1, 2;

-- Cases vs Population - shows % of population with Covid (9/9/22 22.9% of population has Covid)
select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage from coviddeaths where location like "%States%"  order by 1, 2;

-- Countries with Highest infection rate compared to population
select location, population, max(convert(total_cases, double)) as HighestInfectionCount, max(convert(total_cases, double)/population) * 100 as PopulationPercentage from coviddeaths group by location, 
population order by populationPercentage desc;

-- courntries with highest death count per population (United States- Highest wow wow)
select location, max(convert(total_cases, double)) as TotalDeathCount from coviddeaths group by location order by TotalDeathCount desc;

-- Continents with highest death count compared to Population
select continent, MAX(convert(total_deaths, double)) as TotalDeathCount from coviddeaths  group by continent order by TotalDeathCount desc;

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
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations
 from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date order by 2, 3;

-- CTE-common table expression- table to show percentages of vaccinations per population with partition roll up
With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, sumRollVaccinations) as
(select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date )
select *, (sumRollVaccinations/Population) * 100 from PopVsVac; 

With PopVsVac1(Continent, Location,  Population, New_Vaccinations, sumRollVaccinations) as
(select cdea.continent, cdea.location, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date )
select *, (sumRollVaccinations/Population) * 100 from PopVsVac1; 

-- 	Create TABLE
drop table if exists PercentPopulationVaccinnated;

CREATE TABLE PercentPopulationVaccinnated (
Continent varchar(255),
Location varchar(255),
Date varchar(255),
Population numeric,
New_vaccinations varchar(255),
sumRollVaccinations numeric)
 ;
insert into PercentPopulationVaccinnated
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date ;
select *, (sumRollVaccinations/Population) * 100 from percentpopulationvaccinnated;

-- Create Views for visualizations
create view PercentPopulationVaccinnatedView as
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
sum(cvac.new_vaccinations) over (Partition by cdea.location order by cdea.location, cdea.date) as sumRollVaccinations from coviddeaths cdea
join covidvacccinations cvac on cdea.location = cvac.location and cdea.date = cvac.date ;


create view  HighestCovidCountriesView as
select location, population, max(convert(total_cases, double)) as HighestInfectionCount, max(convert(total_cases, double)/population) * 100 as PopulationPercentage from coviddeaths group by location, 
population order by populationPercentage desc;



create view HighestDeathView as 
select location, max(convert(total_cases, double)) as TotalDeathCount from coviddeaths group by location order by TotalDeathCount desc;
select * from HighestDeathview;

create view HighestDeathContinentView as
select continent, MAX(convert(total_deaths, double)) as TotalDeathCount from coviddeaths  group by continent order by TotalDeathCount desc;
select * from highestdeathcontinentview;

Create view GlobalPercentagesDeath as
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100  as DeathPercentage from coviddeaths group by date order by 1, 2;
select * from globalpercentagesdeath;

create view GlobalPercentagesDeath1 as
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100  as DeathPercentage from coviddeaths  order by 1, 2;
select * from globalpercentagesdeath1;

create view covidCasesDeath as
select location, sum(population), sum(new_cases), sum(total_cases), sum(new_deaths), sum(total_deaths) from coviddeaths group by location order by 1;

select * from covidcasesdeath;