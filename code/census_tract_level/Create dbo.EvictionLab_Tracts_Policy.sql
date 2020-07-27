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
--without join,  132 GEOIDs have ct=3 (396 rows in 2016)
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

cts2 as (
--without join,  132 GEOIDs have ct=3 (396 rows in 2016)
select GEOID, count(*) as ct from joined group by GEOID),

dups2 as (

select * from cts2 where cts2.ct > 1)

	,cleaned as (

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

citypop as (
select ttp_Placename, sum(cast(ttp_Population2016est as float)) as city_population from cleaned 
where cleaned.year = 2016
group by ttp_Placename


),

policy as (
select 
Jurisdiction, s.name, s.statefp, s.statens, s.affgeoid, s.stusps, 
Effective_Date,
Valid_Through_Date,
SLT_Law,
SLT_ExemptHotel,
SLT_ExemptRenter_holds_contract_to_purchase_dwelling,
SLT_ExemptOccupancy_by_member_of_social_org_operated_for_org,
SLT_ExemptOccupancy_by_employee_whose_occupancy_conditional_on_employment,
SLT_ExemptOccupancy_by_an_owner_of_a_condominium,
SLT_ExemptOccupancy_under_rental_agreement_for_dwelling_primarily_for_ag,
SLT_Exempt_Public_housing,
SLT_Exempt_Exemptions_not_specified,
SLT_EXEMPT_TOTAL,
SLT_LandlordDutiesMaintain_habitable_conditions,
SLT_LandlordDutiesComply_w_applicable_housing_codes,
SLT_LandlordDutiesMake_repairs,
SLT_LandlordDutiesKeep_common_areas_in_safe_condition,
SLT_LandlordDutiesMaintain_supplied_appliances,
SLT_LandlordDutiesMaintain_appropriate_receptacles_for_waste,
SLT_LandlordDutiesSupply_running_water,
SLT_LandlordDutiesSupply_heat,
SLT_LandlordDuties_Duties_not_specified,
SLT_TenantDutiesComply_w_applicable_housing_codes,
SLT_TenantDutiesKeep_premises_safe,
SLT_TenantDutiesDispose_of_waste,
SLT_TenantDutiesKeep_plumbing_fixtures_clear,
SLT_TenantDutiesUse_appliances_in_a_reasonable_manner,
SLT_TenantDutiesDo_not_destroy_any_part_of_the_dwelling,
SLT_TenantDutiesDo_not_disturb_neighbors,
SLT_TenantDuties_Duties_not_specified,
SLT_LRemediesTerminate_lease,
SLT_LRemediesMonetary_damages,
SLT_LRemediesRetain_security_deposit,
SLT_LRemedies_Landlord_can_make_repairs,
SLT_LRemedies_Remedies_not_specified,
SLT_LREMEDIES_TOTAL,
SLT_TRemediesTerminate_lease,
SLT_TRemediesMonetary_damages,
SLT_TRemedies_Tenant_can_make_repairs,
SLT_TRemedies_Remedies_not_specified,
SLT_TREMEDIES_TOTAL,
SLT_SecurityDeposit,
SLT_Retaliation,
SLT_DV_Yes_they_may_request_lock_change,
SLT_DV_Yes_may_terminate_their_lease,
SLT_DVNo

from dbo.DT_LT_policy as l
join dbo.state_meta as s
on l.Jurisdiction = s.name),

--select ttp_Statecode,  ttp_Stateabbreviation from cleaned
--group by ttp_Statecode,  ttp_Stateabbreviation
--order by ttp_Stateabbreviation

--statefp (01 is alabama), stusps, Jurisdiction, 
--STATE
secondcleaned as (
select 
cleaned.ttp_Statecode,
cleaned.ttp_Stateabbreviation,
cleaned.COUNTY,
cleaned.ttp_Countyname,
cleaned.ttp_CountyCode,
cleaned.COUSUB,
cleaned.PLACE as city_FIPS,
cleaned.ttp_Placecode,
cleaned.ttp_Placename as city,
c.city_population,
cleaned.name as tract_name,
cleaned.population as ttp_tract_population_ACS_est,
cleaned.ttp_Population2016est,
cleaned.evictionrate,
cleaned.evictions,
cleaned.evictionfilingrate,
cleaned.evictionfilings,
cleaned.povertyrate,
cleaned.renteroccupiedhouseholds,
cleaned.pctrenteroccupied,
cleaned.mediangrossrent,
cleaned.medianhouseholdincome,
cleaned.medianpropertyvalue,
cleaned.rentburden,
cleaned.pctwhite,
cleaned.pctafam,
cleaned.pcthispanic,
cleaned.pctamind,
cleaned.pctasian,
cleaned.pctnhpi,
cleaned.pctmultiple,
cleaned.pctother,
cleaned.lowflag,
cleaned.imputed,
cleaned.subbed,
cleaned.parentlocation,
f.FHP_ExemptHousing_TOTAL_ as FHP_ExcemptHousing_TOTAL,
p.SLT_EXEMPT_TOTAL,
p.SLT_LREMEDIES_TOTAL,
p.SLT_TREMEDIES_TOTAL,
p.SLT_SecurityDeposit,
p.SLT_Retaliation,
p.Jurisdiction,
p.name as state_name,
p.statefp,
p.statens,
p.affgeoid,
p.stusps,
p.Effective_Date,
p.Valid_Through_Date,
p.SLT_Law,
p.SLT_ExemptHotel,
p.SLT_ExemptRenter_holds_contract_to_purchase_dwelling,
p.SLT_ExemptOccupancy_by_member_of_social_org_operated_for_org,
p.SLT_ExemptOccupancy_by_employee_whose_occupancy_conditional_on_employment,
p.SLT_ExemptOccupancy_by_an_owner_of_a_condominium,
p.SLT_ExemptOccupancy_under_rental_agreement_for_dwelling_primarily_for_ag,
p.SLT_Exempt_Public_housing,
p.SLT_Exempt_Exemptions_not_specified,
p.SLT_LandlordDutiesMaintain_habitable_conditions,
p.SLT_LandlordDutiesComply_w_applicable_housing_codes,
p.SLT_LandlordDutiesMake_repairs,
p.SLT_LandlordDutiesKeep_common_areas_in_safe_condition,
p.SLT_LandlordDutiesMaintain_supplied_appliances,
p.SLT_LandlordDutiesMaintain_appropriate_receptacles_for_waste,
p.SLT_LandlordDutiesSupply_running_water,
p.SLT_LandlordDutiesSupply_heat,
p.SLT_LandlordDuties_Duties_not_specified,
p.SLT_TenantDutiesComply_w_applicable_housing_codes,
p.SLT_TenantDutiesKeep_premises_safe,
p.SLT_TenantDutiesDispose_of_waste,
p.SLT_TenantDutiesKeep_plumbing_fixtures_clear,
p.SLT_TenantDutiesUse_appliances_in_a_reasonable_manner,
p.SLT_TenantDutiesDo_not_destroy_any_part_of_the_dwelling,
p.SLT_TenantDutiesDo_not_disturb_neighbors,
p.SLT_TenantDuties_Duties_not_specified,
p.SLT_LRemediesTerminate_lease,
p.SLT_LRemediesMonetary_damages,
p.SLT_LRemediesRetain_security_deposit,
p.SLT_LRemedies_Landlord_can_make_repairs,
p.SLT_LRemedies_Remedies_not_specified,
p.SLT_TRemediesTerminate_lease,
p.SLT_TRemediesMonetary_damages,
p.SLT_TRemedies_Tenant_can_make_repairs,
p.SLT_TRemedies_Remedies_not_specified,
p.SLT_DV_Yes_they_may_request_lock_change,
p.SLT_DV_Yes_may_terminate_their_lease,
p.SLT_DVNo,

cleaned.TRACT,
cleaned.ttp_Tract,
cleaned.ttp_GEOID,
cleaned.GEOID,
cleaned.tpp_tracttoplacefpallocationfactor,
cleaned.year
 from cleaned

left join policy as p
on cleaned.ttp_Stateabbreviation = p.stusps
--order by c.ttp_Stateabbreviation, ttp_Tract

left join dbo.Fair_Housing_Data as f
on f.Jurisdictions = p.Jurisdiction

left join citypop as c
on c.ttp_Placename = cleaned.ttp_Placename

left join dbo.AllMissing as a
on a.PLACE = cleaned.PLACE

where cleaned.ttp_placename <> ''
and a.PLACE is null
)

select * 
into  dbo.EvictionLab_Tracts_Policy 
from secondcleaned as s