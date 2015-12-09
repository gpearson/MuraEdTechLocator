/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfset StateAbbr = "">
		<cfswitch expression="#URL.State#">
			<cfcase value="INDIANA">
				<cfset StateAbbr = "IN">
			</cfcase>
			<cfcase value="TENNESSEE">
				<cfset StateAbbr = "TN">
			</cfcase>
		</cfswitch>

		<cfif not isDefined("FORM.formSubmit")>
			<cfif not isDefined("FORM.FormErrors")><cfset Session.FormErrors = #ArrayNew()#></cfif>

			<cfquery name="Session.getSchoolDistrictsInState" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Select NCES_ID, DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, LowestGradeLevel, HighestGradeLevel, Total_NumberStudents, Total_OperationalSchools
				From pSchoolDistricts
				Where PhysicalState = <cfqueryparam value="#Variables.StateAbbr#" cfsqltype="CF_SQL_VARCHAR">
				Order by DistrictName ASC
			</cfquery>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfswitch expression="#FORM.SearchBy#">
				<cfcase value="SchoolBuildings">
					<cfif FORM.SearchType EQ "LT"><cfset SearchField = "Total_OperationalSchools  <"></cfif>
					<cfif FORM.SearchType EQ "GT"><cfset SearchField = "Total_OperationalSchools  >"></cfif>
					<cfif FORM.SearchType EQ "EQ"><cfset SearchField = "Total_OperationalSchools  ="></cfif>
					<cfif FORM.SearchType EQ "LTEQ"><cfset SearchField = "Total_OperationalSchools  <="></cfif>
					<cfif FORM.SearchType EQ "GTEQ"><cfset SearchField = "Total_OperationalSchools  >="></cfif>

					<cfquery name="Session.getSchoolDistrictsInState" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select NCES_ID, DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, LowestGradeLevel, HighestGradeLevel, Total_NumberStudents, Total_OperationalSchools
						From pSchoolDistricts
						Where PhysicalState = <cfqueryparam value="#Variables.StateAbbr#" cfsqltype="CF_SQL_VARCHAR"> and
							#Variables.SearchField# <cfqueryparam value="#FORM.Qty#" cfsqltype="CF_SQL_VARCHAR">
						Order by DistrictName ASC
					</cfquery>
				</cfcase>
				<cfcase value="TotalStudents">
					<cfif FORM.SearchType EQ "LT"><cfset SearchField = "Total_NumberStudents  <"></cfif>
					<cfif FORM.SearchType EQ "GT"><cfset SearchField = "Total_NumberStudents  >"></cfif>
					<cfif FORM.SearchType EQ "EQ"><cfset SearchField = "Total_NumberStudents  ="></cfif>
					<cfif FORM.SearchType EQ "LTEQ"><cfset SearchField = "Total_NumberStudents  <="></cfif>
					<cfif FORM.SearchType EQ "GTEQ"><cfset SearchField = "Total_NumberStudents  >="></cfif>

					<cfquery name="Session.getSchoolDistrictsInState" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select NCES_ID, DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, LowestGradeLevel, HighestGradeLevel, Total_NumberStudents, Total_OperationalSchools
						From pSchoolDistricts
						Where PhysicalState = <cfqueryparam value="#Variables.StateAbbr#" cfsqltype="CF_SQL_VARCHAR"> and
							#Variables.SearchField# <cfqueryparam value="#FORM.Qty#" cfsqltype="CF_SQL_VARCHAR">
						Order by DistrictName ASC
					</cfquery>
				</cfcase>
			</cfswitch>
		</cfif>
	</cffunction>

</cfcomponent>