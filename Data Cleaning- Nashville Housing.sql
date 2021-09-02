-- Cleaning data and make it more usable in sql queries 

select *
from "Nashville_housing" 



--Populate Property Address data

select *
from "Nashville_housing" 
--where propertyaddress is null
order by parcelid 


select nh_1.parcelid, nh_1.propertyaddress, nh_2.parcelid , nh_2.propertyaddress, coalesce(nh_1.propertyaddress, nh_2.propertyaddress)
from "Nashville_housing" nh_1 
join "Nashville_housing" nh_2 
	on nh_1.parcelid = nh_2.parcelid 
	and nh_1."UniqueID " <> nh_2."UniqueID " 
--where nh_1.propertyaddress is null


update "Nashville_housing" 
set propertyaddress = coalesce (nh_1.propertyaddress, nh_2.propertyaddress)
from "Nashville_housing" nh_1 
join "Nashville_housing" nh_2 
	on nh_1.parcelid = nh_2.parcelid 
	and nh_1."UniqueID " <> nh_2."UniqueID " 
where nh_1.propertyaddress is null


--Breaking out property address into individual columns(address, city)


select
substring(propertyaddress, 1, position (',' in propertyaddress)-1) as address
,substring(propertyaddress, position (',' in propertyaddress)+1, length(propertyaddress))   as address
from "Nashville_housing" 


alter table "Nashville_housing" 
add propertysplitaddress varchar(255);

update "Nashville_housing" 
set propertysplitaddress = substring(propertyaddress, 1, position (',' in propertyaddress)-1)

alter table "Nashville_housing" 
add propertysplitcity varchar(255);

update "Nashville_housing" 
set propertysplitcity = substring(propertyaddress, position (',' in propertyaddress)+1, length(propertyaddress))




--Breaking out property address into individual columns(address, city, state)

select 
split_part(owneraddress,',',1)
,split_part(owneraddress,',',2)
,split_part(owneraddress,',',3)
from "Nashville_housing" nh 


alter table "Nashville_housing"
add ownersplitaddress varchar(255);

update "Nashville_housing"
set ownersplitaddress = split_part(owneraddress, ',', 1);


alter table "Nashville_housing" 
add ownersplitcity varchar(255);

update "Nashville_housing" 
set ownersplitcity = split_part(owneraddress, ',', 2); 


alter table "Nashville_housing" 
add ownersplitstate varchar(255);

update "Nashville_housing" 
set ownersplitstate = split_part(owneraddress, ',', 3); 




-- change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant)
from "Nashville_housing"  
group by soldasvacant 
order by 2



select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
	  when soldasvacant = 'N' then 'No'
	  else soldasvacant 
	  end
from "Nashville_housing" 


update "Nashville_housing" 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	  when soldasvacant = 'N' then 'No'
	  else soldasvacant 
	  end


	  
-- remove duplicates

with RowNumCTE as(
select "UniqueID " 
, row_number() over(
	partition by parcelid,
				propertyaddress,
				saleprice ,
				saledate ,
				legalreference 
				order by "UniqueID " 
				) as row_num
from "Nashville_housing" nh 
)
delete
from "Nashville_housing" 
where "UniqueID " in (select "UniqueID " from RowNumCTE where row_num > 1);




--delete unused columns

alter table "Nashville_housing" 
drop column  owneraddress,
drop column  propertyaddress,
drop column  taxdistrict

	  
	  
	  

	  


	  
	  
	  
	  