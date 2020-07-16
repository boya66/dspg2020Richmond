
select
substring(t.GEOID,1,7) as subtractgeoid, t.GEOID as tractgeoid, c.GEOID as citygeoid,
c.year as c_year
, t.year as t_year
, c.name as c_name
, t.name as t_name
, c.population as c_population
, t.population as t_population
, c.povertyrate as c_povertyrate
, t.povertyrate as t_povertyrate
, c.GEOID as c_GEOID
, t.GEOID as t_GEOID
, c.renteroccupiedhouseholds as c_renteroccupiedhouseholds
, t.renteroccupiedhouseholds as t_renteroccupiedhouseholds
, c.pctrenteroccupied as c_pctrenteroccupied
, t.pctrenteroccupied as t_pctrenteroccupied
, c.mediangrossrent as c_mediangrossrent
, t.mediangrossrent as t_mediangrossrent
, c.medianhouseholdincome as c_medianhouseholdincome
, t.medianhouseholdincome as t_medianhouseholdincome
, c.medianpropertyvalue as c_medianpropertyvalue
, t.medianpropertyvalue as t_medianpropertyvalue
, c.rentburden as c_rentburden
, t.rentburden as t_rentburden
, c.pctwhite as c_pctwhite
, t.pctwhite as t_pctwhite
, c.pctafam as c_pctafam
, t.pctafam as t_pctafam
, c.pcthispanic as c_pcthispanic
, t.pcthispanic as t_pcthispanic
, c.pctamind as c_pctamind
, t.pctamind as t_pctamind
, c.pctasian as c_pctasian
, t.pctasian as t_pctasian
, c.pctnhpi as c_pctnhpi
, t.pctnhpi as t_pctnhpi
, c.pctmultiple as c_pctmultiple
, t.pctmultiple as t_pctmultiple
, c.pctother as c_pctother
, t.pctother as t_pctother
, c.evictionfilings as c_evictionfilings
, t.evictionfilings as t_evictionfilings
, c.evictions as c_evictions
, t.evictions as t_evictions
, c.evictionrate as c_evictionrate
, t.evictionrate as t_evictionrate
, c.evictionfilingrate as c_evictionfilingrate
, t.evictionfilingrate as t_evictionfilingrate
, c.lowflag as c_lowflag
, t.lowflag as t_lowflag
, c.imputed as c_imputed
, t.imputed as t_imputed
, c.subbed as c_subbed
, t.subbed as t_subbed
, c.parentlocation as c_parentlocation
, t.parentlocation as t_parentlocation


from DT_tracts as t

join dt_cities as c --2,677 rows
on substring(t.GEOID,1,7) = c.GEOID
and t.year = c.year
and t.year = 2016

--join dt_cities as c --776 rows
--on substring(t.GEOID,1,6) = c.GEOID
--and t.year = c.year
--and t.year = 2016

select len(GEOID), count(*) from dt_cities group by len(GEOID) order by len(GEOID)
--some length of 6, some length of 7
select * from dt_cities where len(GEOID) = 6 and year = 2016

--45,509 rows
select * from dt_cities where year = 2016 --29, 807



--Q: How to find richmond in the tracts and cities datasets to join them? But, they have different GEOIDs
select substring(GEOID,1,7), * from DT_tracts where GEOID like '51760%' and year = 2016 order by GEOID asc --yup 
select * from DT_cities where name = 'Richmond' and year = 2016 and GEOID like '%5167000%'
5100148

--work to parse 'city' name from parent-location, but this only works for incorporated ciites in Virginia, so it's not useful for national level
create function dbo.fnLastIndexOf(@text varChar(max),@char varchar(1))
returns int
as
begin
return len(@text) - charindex(@char, reverse(@text)) -1
end

select parentlocation, 
dbo.fnLastIndexOf(parentlocation, 'city'),
substring(parentlocation, 1, dbo.fnLastIndexOf(parentlocation, 'city')),
* from DT_tracts where GEOID like '51760%' and year = 2016