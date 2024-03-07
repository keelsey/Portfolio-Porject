--DATA CLEANING
--CREATE TABLE
create table housing_data(
UniqueID int,
ParcelID varchar,
LandUse varchar,
PropertyAddress varchar,
SaleDate varchar,
SalePrice varchar,
LegalReference varchar,
SoldAsVacant varchar,
OwnerName varchar,
OwnerAddress varchar,
Acreage varchar,
TaxDistrict varchar,
LandValue varchar,
BuildingValue varchar,
TotalValue varchar,
YearBuilt varchar,
Bedrooms varchar,
FullBath varchar,
HalfBath varchar
);

drop table housing_data;

copy housing_data
from '/Applications/PostgreSQL 16/data/Nashville Housing Data for Data Cleaning.csv'
delimiter ','
csv header;

select * from housing_data;

--Standardize the date
select to_char(to_date(saledate, 'Month DD, YYYY'), 'YYYY-MM-DD') as saledate
from housing_data;

update housing_data
set saledate = to_char(to_date(saledate, 'Month DD, YYYY'), 'YYYY-MM-DD');

alter table housing_data
alter column saledate type date using saledate::date;

--POPULATE ADDRESS DATA

select * from housing_data
where propertyaddress is null
order by parcelid;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
from housing_data as a
join housing_data as b
on a.parcelid = b.parcelid
and a.uniqueid is distinct from b.uniqueid
where a.propertyaddress is null
;

update housing_data as a
set propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
from housing_data as b
where a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
and a.propertyaddress is null;

--breaking out address into individual columns
select propertyaddress from housing_data
order by parcelid;

select propertyaddress, parcelid,
substring(propertyaddress for 4) as house_number
from housing_data
order by parcelid;

select propertyaddress, parcelid,
split_part(propertyaddress, ',', 1) as house_number
from housing_data
order by parcelid;


select propertyaddress, parcelid,
split_part(propertyaddress, ',', 1) as house_number,
split_part(propertyaddress, ',', 2) as house_number
from housing_data
order by parcelid;

alter table housing_data
add column propertyaddress_street text,
add column propertyaddress_city text;

update housing_data
set propertyaddress_street = split_part(propertyaddress, ',', 1),
	propertyaddress_city = split_part(propertyaddress, ',', 2);
	
select * from housing_data;

--alter table housing_data
--drop column propertyaddress_city;

alter table housing_data
add column owneraddress_street text,
add column owneraddress_city text,
add column owneraddress_state text;

update housing_data
set owneraddress_street = split_part(owneraddress, ',', 1),
	owneraddress_city = split_part(owneraddress, ',', 2),
	owneraddress_state = split_part(owneraddress, ',', 3);

--change y and n to yes and no in solid at vacant field
select distinct (soldasvacant)
from housing_data;

update housing_data
set soldasvacant = 'Yes'
where soldasvacant = 'Y';

update housing_data 
set soldasvacant = 'No'
where soldasvacant = 'N';

/*case statement
select case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
		end 

Update housing_data
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
		end 
*/

--remove duplicates
with ROW_NUMCTE as(
	select * , row_number() over(partition by parcelid, propertyaddress, saleprice, saledate, legalreference order by uniqueid ) as row_number
	from housing_data
	--order by parcelid;
)
select *
from ROW_NUMCTE ;
--where row_number >1;

delete from housing_data
where (parcelid, propertyaddress, saleprice, saledate, legalreference, uniqueid) in (
    select parcelid, propertyaddress, saleprice, saledate, legalreference, uniqueid
    from (
        select *,
               row_number() over(partition by parcelid, propertyaddress, saleprice, saledate, legalreference order by uniqueid) as row_number
        from housing_data
    ) as ROW_NUMCTE
    where row_number > 1
);

--delete unused columns
alter table housing_data
drop column propertyaddress;

alter table housing_data
drop column owneraddress;

alter table housing_data
drop column taxdistrict;

select * from housing_data
order by uniqueid;