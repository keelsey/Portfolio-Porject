create table Covid_Deaths(
iso_code varchar,
continent varchar,
location varchar,
date date,
population int,
total_cases int,
new_cases int,
new_cases_smoothed double precision,
total_deaths int,
new_deaths int,
new_deaths_smoothed double precision,
total_cases_per_million double precision,
new_cases_per_million double precision,
new_cases_smoothed_per_million double precision,
total_deaths_per_million double precision,
new_deaths_per_million double precision,
new_deaths_smoothed_per_million double precision,
reproduction_rate double precision,
icu_patients double precision,
icu_patients_per_million double precision,
hosp_patients double precision,
hosp_patients_per_million double precision,
weekly_icu_admissions double precision,
weekly_icu_admissions_per_million double precision,
weekly_hosp_admissions double precision,
weekly_hosp_admissions_per_million double precision);

select * from covid_deaths;

copy Covid_Deaths
from '/Applications/PostgreSQL 16/data/CovidDeaths 1.csv'
delimiter ','
csv header;

Alter table covid_deaths
alter column population
type bigint;

alter table covid_deaths
alter column date
type date;

--select data going to be used
select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where location = 'International';
--order by location;

--total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths::decimal/total_cases)*100 as percentage_deaths
from covid_deaths
order by location, date;

-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, round((total_deaths::decimal/total_cases)*100, 2) as percentage_deaths
from covid_deaths
where location = 'Africa'
order by location, date;

--looking at total cases vs population
--shows what percentage as contracted covid
select location, date,population, total_cases, round((total_cases::decimal/population)*100, 2) as percentage_cases
from covid_deaths
--where location = 'Africa'
order by location, date;

/*select location, population, total_cases
from covid_deaths
where location = 'International';
*/

--Countries with highest infection rate compare to population
select location, population, max(total_cases) as highestcovidcase, round(max((total_cases::decimal/population)) * 100, 2) as "Percentage population infected"
from covid_deaths
group by location, population
order by "Percentage population infected" desc nulls last;

--Countries with highest death rate compare to population
select location, population, max(total_deaths) as highestdeaths, max((total_deaths::decimal/population)) * 100 as "Percentage population deaths"
from covid_deaths
group by location, population
order by "Percentage population deaths" desc nulls last;

--countries with highest death rate per population
select location, max(total_deaths) as "Total Deaths"
from covid_deaths
where continent is not null
group by location
order by "Total Deaths" desc nulls last;

--total deaths by continents
select location, max(total_deaths) as "Total Deaths"
from covid_deaths
where continent is null
group by location
order by "Total Deaths" desc;

select continent, max(total_deaths) as "Total Deaths"
from covid_deaths
where continent is not null
group by continent
order by "Total Deaths" desc;

--continent with highest death count
select location, max(total_deaths) as "Total Deaths"
from covid_deaths
where continent is null
group by location
order by "Total Deaths" desc;

--GLOBAL NUMBERS

select /*date,*/ sum(new_cases) as "Total case", sum(new_deaths) as "Total Deaths", round((sum(new_deaths)::decimal/sum(new_cases))*100, 2) as "Death Percentage"
from covid_deaths
where continent is not null
--group by date
order by /*date,*/ "Total case";

select * from covid_vaccination;
drop table covid_vaccination;
create table Covid_Vaccination(
iso_code varchar,
continent varchar,
location varchar,
date date,
new_tests double precision,
total_tests double precision,
total_tests_per_thousand double precision,
new_tests_per_thousand double precision,
new_tests_smoothed double precision,
new_tests_smoothed_per_thousand double precision,
positive_rate double precision,
tests_per_case double precision,
tests_units double precision,
total_vaccinations double precision,
people_vaccinated double precision,
people_fully_vaccinated double precision,
new_vaccinations double precision,
new_vaccinations_smoothed double precision,
total_vaccinations_per_hundred double precision,
people_vaccinated_per_hundred double precision,
people_fully_vaccinated_per_hundred double precision,
new_vaccinations_smoothed_per_million double precision,
stringency_index double precision,
population_density double precision,
median_age double precision,
aged_65_older double precision,
aged_70_older double precision,
gdp_per_capita double precision,
extreme_poverty double precision,
cardiovasc_death_rate double precision,
diabetes_prevalence double precision,
female_smokers double precision,
male_smokers double precision,
handwashing_facilities double precision,
hospital_beds_per_thousand double precision,
life_expectancy double precision,
human_development_index double precision
);

select * from covid_vaccination;

alter table covid_vaccination
alter column tests_units
type varchar;

copy covid_vaccination
from '/Applications/PostgreSQL 16/data/CovidVaccinations1.csv'
delimiter ','
csv header;
-- join both tables
select a.*, b.*
from covid_deaths as a
join covid_vaccination as b
on a.location = b.location and a.date = b.date;

--total population vs vaccination
select a.continent, 
		a.location,
		a.date,
		a.population,
		b.new_vaccinations,
		sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as total_vaccination
from covid_deaths as a
join covid_vaccination as b
on a.location = b.location and a.date = b.date
where a.continent is not null
order by a.location, a.date;

--USING CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccination,total_vaccination)
as (
	select a.continent, 
		a.location,
		a.date,
		a.population,
		b.new_vaccinations,
		sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as total_vaccination
from covid_deaths as a
join covid_vaccination as b
on a.location = b.location and a.date = b.date
where a.continent is not null
order by a.location, a.date
)
select *, round((total_vaccination::decimal/population) *100, 2) as percentage_vac
from PopvsVac;


--create temp table

--view for visualization
create view Percentage_Poulation_Vaccinated as
select a.continent, 
		a.location,
		a.date,
		a.population,
		b.new_vaccinations,
		sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as total_vaccination
from covid_deaths as a
join covid_vaccination as b
on a.location = b.location and a.date = b.date
where a.continent is not null
order by a.location, a.date;
