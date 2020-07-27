;with cte as (
select 
GEOID,[year],[name],[population],povertyrate,renteroccupiedhouseholds,
pctrenteroccupied,mediangrossrent,medianhouseholdincome,
medianpropertyvalue,rentburden,pctwhite,pctafam,pcthispanic,
pctamind,pctasian,pctnhpi,pctmultiple,pctother,evictionfilings,
evictions,evictionrate,evictionfilingrate,lowflag,imputed,
subbed,parentlocation

from dt_tracts
--where year = 2016
group by
GEOID,[year],[name],[population],povertyrate,renteroccupiedhouseholds,
pctrenteroccupied,mediangrossrent,medianhouseholdincome,
medianpropertyvalue,rentburden,pctwhite,pctafam,pcthispanic,
pctamind,pctasian,pctnhpi,pctmultiple,pctother,evictionfilings,
evictions,evictionrate,evictionfilingrate,lowflag,imputed,
subbed,parentlocation),

cts as (
select GEOID, count(*) as ct from cte group by GEOID),

dups as (

select * from cts where cts.ct > 1),

joined as (
select  
--dbo.fnLastIndexOf(parentlocation, 'city'),
--substring(GEOID,1,2) as STATE, 
substring(GEOID,3,3) as COUNTY, substring(GEOID,5,5) as COUSUB, substring(GEOID, 5,8) as PLACE,
substring(GEOID, 6,6) as TRACT,
(ttp.Countycode + '0' + left( rtrim(replace(ttp.tract,'.','')) + '0000000', 5))  as ttp_GEOID,
ttp.CountyCode as ttp_CountyCode, ttp.Tract as ttp_Tract, ttp.Statecode as ttp_Statecode,
ttp.Placecode as ttp_Placecode, ttp.Stateabbreviation as ttp_Stateabbreviation,
ttp.Countyname as ttp_Countyname, ttp.Placename as ttp_Placename, ttp.Population2016est as ttp_Population2016est,
ttp.tracttoplacefpallocationfactor as tpp_tracttoplacefpallocationfactor,
--substring(parentlocation, 1, dbo.fnLastIndexOf(parentlocation, 'city')) as CITY_PARSED_PL,
--(ttp.Countycode + '0' + LEFT(ISNULL(replace(ttp.tract,'.',''),'')+'00',5)) as ttp_GEOID,
--(ttp.Countycode + '0' + left( rtrim(replace(ttp.tract,'.','')) + '0000000', 5)) as ttp_GEOID,
t.* from cte as t 

--where GEOID like '51760%' and year = 2016 and substring(GEOID, 6,6) = '010200'
left join dbo.dt_tracts_to_places as ttp
--on t.GEOID = (ttp.Countycode + '0' + LEFT(ISNULL(rtrim(replace(ttp.tract,'.','')),'')+'00',5))
on t.GEOID = (ttp.Countycode + '0' + left( rtrim(replace(ttp.tract,'.','')) + '0000000', 5)) 

--where 
--year = 2016
),

cleaned as (

select 
--[STATE], 
ttp_Statecode,  ttp_Stateabbreviation, COUNTY, ttp_Countyname, ttp_CountyCode, COUSUB, PLACE, ttp_Placecode,
 ttp_Placename, TRACT, ttp_Tract, ttp_GEOID, GEOID, tpp_tracttoplacefpallocationfactor, 
 --isnull(replace(tpp_tracttoplacefpallocationfactor,'',0),0)*isnull(replace(ttp_Population2016est,'',0),0) as AllocationPop

[year],[name],[population],  ttp_Population2016est, povertyrate,renteroccupiedhouseholds,
pctrenteroccupied,mediangrossrent,medianhouseholdincome,
medianpropertyvalue,rentburden,pctwhite,pctafam,pcthispanic,
pctamind,pctasian,pctnhpi,pctmultiple,pctother,evictionfilings,
evictions,evictionrate,evictionfilingrate,lowflag,imputed,
subbed,parentlocation 

from joined

--where ttp_Placename is not null
where cast(ttp_Statecode as int) in('1','4','5','6','8','9','10','11','12','13','16','17','18',
'19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38',
'39','40','41','42','44','45','46','47','48','49','50','51','53','54','55','56')
and year = 2016
and ttp_placename <> ''
group by
-- [STATE],
COUNTY, COUSUB, PLACE, TRACT, ttp_GEOID, GEOID,[year],[name],[population],povertyrate,renteroccupiedhouseholds,
pctrenteroccupied,mediangrossrent,medianhouseholdincome,
medianpropertyvalue,rentburden,pctwhite,pctafam,pcthispanic,
pctamind,pctasian,pctnhpi,pctmultiple,pctother,evictionfilings,
evictions,evictionrate,evictionfilingrate,lowflag,imputed,
subbed,parentlocation,
ttp_GEOID,
ttp_CountyCode, ttp_Tract, ttp_Statecode,
ttp_Placecode, ttp_Stateabbreviation,
ttp_Countyname, ttp_Placename, ttp_Population2016est,
tpp_tracttoplacefpallocationfactor

),

summary as (

select PLACE, GEOID, case when evictionrate = '' or evictionrate is null then 1 else 0 end as IsMissing from cleaned 


group by PLACE, GEOID, case when evictionrate = '' or evictionrate is null then 1 else 0 end

),

summ2 as (

select PLACE, count(*) as NumTracts, sum(isMissing) as NumMissing  from summary

group by PLACE) select * from summ2

select summ2.* 
into dbo.AllMissing 
from summ2 
join cleaned as c
on c.PLACE = summ2.PLACE
where NumTracts = NumMissing 

select * from dbo.AllMissing