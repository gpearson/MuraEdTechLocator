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
			<h3 class="t">Import Zipcode Data into Database</h3>
		</div>
		<div class="art-blockcontent">
			<p class="alert-box notice">Please complete the following information to select the Comma Seperated Zip Code Database File that will be used to populate the Database Table.<br /></p>
			<hr>
			<cfif not isDefined("FORM.formSubmit")>
				<cfquery name="getUSZipCodes" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Distinct StateFIPS
					From pZipCodes
				</cfquery>
				<cfset ActiveZipCodes = #ValueList(getUSZipCodes.StateFIPS)#>
				<uForm:form action="" method="Post" id="ImportZipCodeDatabase" errors="#Session.FormErrors#" errorMessagePlacement="both"
					commonassetsPath="/plugins/1To1TechLocator/library/uniForm/" showCancel="yes" cancelValue="<--- Return to Menu" cancelName="cancelButton"
					cancelAction="?#HTMLEditFormat(rc.pc.getPackage())#action=admin:utilities.default&compactDisplay=false"
					submitValue="Import Database" loadValidation="true" loadMaskUI="true" loadDateUI="true"
					loadTimeUI="true">
					<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<input type="hidden" name="formSubmit" value="true">
					<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<input type="hidden" name="formSubmit" value="true">
					<uform:Fieldset legend="Which State to Import information from?">
						<uform:field label="Select ZipCode Prefix to Import" name="ImportUSZipCodePrefix" type="select" hint="Select the US ZipCode you would like to import information from?">
							<cfif not ListContains(Variables.ActiveZipCodes, "1")><uform:option display="Alabama" value="1" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "2")><uform:option display="Alaska" value="2" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "4")><uform:option display="Arizona" value="4" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "5")><uform:option display="Arkansas" value="5" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "6")><uform:option display="California" value="6" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "8")><uform:option display="Colorado" value="8" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "9")><uform:option display="Connecticut" value="9" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "10")><uform:option display="Delaware" value="10" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "12")><uform:option display="Florida" value="12" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "13")><uform:option display="Georgia" value="13" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "15")><uform:option display="Hawaii" value="15" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "16")><uform:option display="Idaho" value="16" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "17")><uform:option display="Illinois" value="17" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "18")><uform:option display="Indiana" value="18" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "19")><uform:option display="Iowa" value="19" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "20")><uform:option display="Kansas" value="20" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "21")><uform:option display="Kentucky" value="21" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "22")><uform:option display="Louisiana" value="22" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "23")><uform:option display="Maine" value="23" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "24")><uform:option display="Maryland" value="24" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "25")><uform:option display="Massachusetts" value="25" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "26")><uform:option display="Michigan" value="26" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "27")><uform:option display="Minnesota" value="27" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "28")><uform:option display="Mississippi" value="28" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "29")><uform:option display="Missouri" value="29" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "30")><uform:option display="Montana" value="30" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "31")><uform:option display="Nebraska" value="31" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "32")><uform:option display="Nevada" value="32" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "33")><uform:option display="New Hampshire" value="33" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "34")><uform:option display="New Jersey" value="34" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "35")><uform:option display="New Mexico" value="35" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "36")><uform:option display="New York" value="36" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "37")><uform:option display="North Carolina" value="37" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "38")><uform:option display="North Dakota" value="38" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "39")><uform:option display="Ohio" value="39" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "40")><uform:option display="Oklahoma" value="40" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "41")><uform:option display="Oregon" value="41" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "42")><uform:option display="Pennsylvania" value="42" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "44")><uform:option display="Rhode Island" value="44" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "45")><uform:option display="South Carolina" value="45" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "46")><uform:option display="South Dakota" value="46" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "47")><uform:option display="Tennessee" value="47" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "48")><uform:option display="Texas" value="48" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "49")><uform:option display="Utah" value="49" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "50")><uform:option display="Vermont" value="50" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "51")><uform:option display="Virginia" value="51" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "53")><uform:option display="Washington" value="53" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "54")><uform:option display="West Virginia" value="54" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "55")><uform:option display="Wisconsin" value="55" /></cfif>
							<cfif not ListContains(Variables.ActiveZipCodes, "56")><uform:option display="Wyoming" value="56" /></cfif>
						</uform:field>
					</uform:Fieldset>
				</uForm:form>
			</cfif>
		</div>
	</div>
</cfoutput>

