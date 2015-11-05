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
			<h3 class="t">Import NCES School Building Data into Database</h3>
		</div>
		<div class="art-blockcontent">
			<p class="alert-box notice">Please complete the following information to select the Comma Seperated School Database File that will be used to populate the Database Table.</p>
			<hr>
			<cfif not isDefined("FORM.formSubmit")>
				<uForm:form action="" method="Post" id="ImportZipCodeDatabase" errors="#Session.FormErrors#" errorMessagePlacement="both"
					commonassetsPath="/plugins/1To1TechLocator/library/uniForm/" showCancel="yes" cancelValue="<--- Return to Menu" cancelName="cancelButton"
					cancelAction="?#HTMLEditFormat(rc.pc.getPackage())#action=admin:utilities.default&compactDisplay=false"
					submitValue="Import Database" loadValidation="true" loadMaskUI="true" loadDateUI="true"
					loadTimeUI="true">
					<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<input type="hidden" name="formSubmit" value="true">
					<uForm:fieldset legend="CSV File to Upload">
						<uform:field label="School Data" name="CSVFileToUpload" type="file" />
					</uForm:fieldset>
				</uForm:form>
			<cfelseif isDefined("FORM.formSubmit")>
				<cfdump var="#FORM#">
			</cfif>
		</div>
	</div>
</cfoutput>
