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
			<h3 class="t">Generate USA Map Data Files</h3>
		</div>
		<div class="art-blockcontent">
			<p class="alert-box notice">Please submit this form to generate the XML Data Files used in the Flash USA Map on the main homepage.</p>
			<hr>
			<cfif not isDefined("FORM.formSubmit")>
				<uForm:form action="" method="Post" id="GenerateUSAMapDataFiles" errors="#Session.FormErrors#" errorMessagePlacement="both"
					commonassetsPath="/plugins/1To1TechLocator/library/uniForm/" showCancel="yes" cancelValue="<--- Return to Menu" cancelName="cancelButton"
					cancelAction="?#HTMLEditFormat(rc.pc.getPackage())#action=admin:utilities.default&compactDisplay=false"
					submitValue="Generate Map Data" loadValidation="true" loadMaskUI="true" loadDateUI="true"
					loadTimeUI="true">
					<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<input type="hidden" name="formSubmit" value="true">
					<uform:Fieldset legend="Generate Map Data Files">
						<uform:field label="Generate Files" name="CreateMapXMLDataFiles" type="select" hint="Generate XML Data Files?">
							<uform:option display="Yes" value="1" />
							<uform:option display="No" value="0" />
						</uform:field>
					</uform:Fieldset>
				</uForm:form>
			</cfif>
		</div>
	</div>
</cfoutput>