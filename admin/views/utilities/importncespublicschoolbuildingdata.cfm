<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2014 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfimport taglib="/plugins/1To1TechLocator/library/uniForm/tags/" prefix="uForm">
<cfoutput>
	<div class="art-block clearfix">
		<div class="art-blockheader">
			<h3 class="t">Import NCES Public School Building Data into Database</h3>
		</div>
		<div class="art-blockcontent">
			<p class="alert-box notice">Please complete the following information to select the Comma Seperated Public School Database File that will be used to populate the Database Table.<br />If you currently do not have this file you can retrieve the information from visiting <a href="http://nces.ed.gov/ccd/elsi/">http://nces.ed.gov/ccd/elsi/</a></p>
			<hr>
			<cfif not isDefined("FORM.formSubmit")>
				<cfquery name="getSchoolBuildingStates" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select PhysicalState
					From pSchoolBuildings
					Group By PhysicalState
					Order by PhysicalState ASC
				</cfquery>
				<cfset ActiveStates = #ValueList(getSchoolBuildingStates.PhysicalState)#>
				<uForm:form action="" method="Post" id="ImportZipCodeDatabase" errors="#Session.FormErrors#" errorMessagePlacement="both"
					commonassetsPath="/plugins/1To1TechLocator/library/uniForm/" showCancel="yes" cancelValue="<--- Return to Menu" cancelName="cancelButton"
					cancelAction="?#HTMLEditFormat(rc.pc.getPackage())#action=admin:utilities.default&compactDisplay=false"
					submitValue="Import Database" loadValidation="true" loadMaskUI="true" loadDateUI="true"
					loadTimeUI="true">
					<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<input type="hidden" name="formSubmit" value="true">
					<uform:Fieldset legend="Which State to Import information from?">
						<uform:field label="Select State to Import From" name="ImportStateSchoolBuildings" type="select" hint="Select the State you would like to import information from?">
							<cfif not ListContains(Variables.ActiveStates, "AL")><uform:option display="Alabama" value="AL" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "AK")><uform:option display="Alaska" value="AK" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "AZ")><uform:option display="Arizona" value="AZ" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "AR")><uform:option display="Arkansas" value="AR" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "CA")><uform:option display="California" value="CA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "CO")><uform:option display="Colorado" value="CO" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "CT")><uform:option display="Connecticut" value="CT" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "DE")><uform:option display="Delaware" value="DE" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "FL")><uform:option display="Florida" value="FL" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "GA")><uform:option display="Georgia" value="GA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "HI")><uform:option display="Hawaii" value="HI" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "ID")><uform:option display="Idaho" value="ID" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "IL")><uform:option display="Illinois" value="IL" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "IN")><uform:option display="Indiana" value="IN" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "IA")><uform:option display="Iowa" value="IA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "KS")><uform:option display="Kansas" value="KS" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "KY")><uform:option display="Kentucky" value="KY" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "LA")><uform:option display="Louisiana" value="LA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "ME")><uform:option display="Maine" value="ME" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MD")><uform:option display="Maryland" value="MD" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MA")><uform:option display="Massachusetts" value="MA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MI")><uform:option display="Michigan" value="MI" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MN")><uform:option display="Minnesota" value="MN" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MS")><uform:option display="Mississippi" value="MS" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MO")><uform:option display="Missouri" value="MO" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "MT")><uform:option display="Montana" value="MT" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NE")><uform:option display="Nebraska" value="NE" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NV")><uform:option display="Nevada" value="NV" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NH")><uform:option display="New Hampshire" value="NH" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NJ")><uform:option display="New Jersey" value="NJ" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NM")><uform:option display="New Mexico" value="NM" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NY")><uform:option display="New York" value="NY" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "NC")><uform:option display="North Carolina" value="NC" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "ND")><uform:option display="North Dakota" value="ND" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "OH")><uform:option display="Ohio" value="OH" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "OK")><uform:option display="Oklahoma" value="OK" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "OR")><uform:option display="Oregon" value="OR" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "PA")><uform:option display="Pennsylvania" value="PA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "RI")><uform:option display="Rhode Island" value="RI" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "SC")><uform:option display="South Carolina" value="SC" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "SD")><uform:option display="South Dakota" value="SD" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "TN")><uform:option display="Tennessee" value="TN" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "TX")><uform:option display="Texas" value="TX" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "UT")><uform:option display="Utah" value="UT" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "VT")><uform:option display="Vermont" value="VT" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "VA")><uform:option display="Virginia" value="VA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "WA")><uform:option display="Washington" value="WA" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "WV")><uform:option display="West Virginia" value="WV" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "WI")><uform:option display="Wisconsin" value="WI" /></cfif>
							<cfif not ListContains(Variables.ActiveStates, "WY")><uform:option display="Wyoming" value="WY" /></cfif>
						</uform:field>
					</uform:Fieldset>
				</uForm:form>
			</cfif>
		</div>
	</div>
</cfoutput>

