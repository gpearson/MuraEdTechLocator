<cfimport taglib="/plugins/1To1TechLocator/library/uniForm/tags/" prefix="uForm">
<cfif not isDefined("URL.State")><cflocation url="/index.cfm"></cfif>
<cfif isDefined("URL.State")>
	<cfoutput>
		<div class="alert-box notice"><p style="Font-Family: Arial; Font-Weight: Bold; Font-Size: 26px;">Viewing School District Information for #URL.State#</p><p align="Center"><a href="/index.cfm">Click Here</a> to return to the State Map to select another state</p></div>
		<uForm:form action="" method="Post" id="SearchResults" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Filter Results" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="formSubmit" value="true">
				<input type="hidden" name="StateToPopulate" value="#URL.State#">
			<uForm:fieldset legend="Search Criteria">
				<uForm:field label="Search By" name="SearchBy" isRequired="true" isDisabled="false" type="select" hint="How do you want to filter results">
					<uform:option display="School Buildings" value="SchoolBuildings" isSelected="true" />
					<uform:option display="Total Students" value="TotalStudents" />
				</uForm:field>
				<uForm:field label="What Type of Results" name="SearchType" isRequired="true" isDisabled="false" type="select" hint="How many results are you wanting to see">
					<uform:option display="Less Than" value="LT" isSelected="true" />
					<uform:option display="Greater Than" value="GT" />
					<uform:option display="Equals" value="EQ"  />
					<uform:option display="Less Than or Equal To" value="LTEQ" />
					<uform:option display="Greater Than or Equal To" value="GTEQ"  />
				</uForm:field>
				<uForm:field label="Search Quantity" name="Qty" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Limit Results to What Number" />
			</uForm:fieldset>
		</uForm:form>
		<br />
		<table class="art-article" style="width: 100%;">
		<thead>
			<tr bgcolor="##CCCCCC" style="Font-Family: Arial; Font-Weight: Bold; Font-Size: 14px;">
				<td>School District</td>
				<td>Physical Address</td>
				<td>Primary Phone Number</td>
				<td>Total School Buildings</td>
				<td>Total Students</td>
				<td>Lowest / Highest Grade Level</td>
				<td>&nbsp;</td>
			</tr>
		</thead>
		<tbody>
			<cfif Session.getSchoolDistrictsInState.RecordCount>
				<cfloop query="Session.getSchoolDistrictsInState">
				<tr bgcolor="<cfif (Session.getSchoolDistrictsInState.currentRow MOD 2 EQ 0)>##FFFFFF<cfelse>##EEEEEE</cfif>">
				<td>#Session.getSchoolDistrictsInState.DistrictName#</td>
				<td>#Session.getSchoolDistrictsInState.PhysicalAddress# #Session.getSchoolDistrictsInState.PhysicalCity# #Session.getSchoolDistrictsInState.PhysicalZipCode#</td>
				<td>#Session.getSchoolDistrictsInState.PrimaryVoiceNumber#</td>
				<td>#Session.getSchoolDistrictsInState.Total_OperationalSchools#</td>
				<td>#Session.getSchoolDistrictsInState.Total_NumberStudents#</td>
				<td>#Session.getSchoolDistrictsInState.LowestGradeLevel# / #Session.getSchoolDistrictsInState.HighestGradeLevel#</td>
				<td>View</td>
				</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="7"><div class="alert-box error"><p style="Align: Center; Font-Family: Arial; Font-Weight: Bold; Font-Size: 26px;">No School Districts Matched your Search Criteria. Please try again.<br /><a href="/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=#URL.State#">Click Here</a> to view all Districts within selected State</p></div></td>
				</tr>
			</cfif>

		</tbody>
	</table></cfoutput>
</cfif>