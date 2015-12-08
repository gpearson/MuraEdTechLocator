<cfimport taglib="/plugins/1To1TechLocator/library/uniForm/tags/" prefix="uForm">
<cfif not isDefined("URL.FormRetry")>
	<cflock timeout="60" scope="SESSION" type="Exclusive">
		<cfset Session.FormData = #StructNew()#>
		<cfset Session.FormErrors = #ArrayNew()#>
	</cflock>
	<cfoutput>
		<h2>Contact Us to Populate State Information</h2>
		<p class="alert-box notice">Please complete the following information to let us know the intent to populate a state with School Districts and School Buildings.</p>
		<hr>
		<uForm:form action="" method="Post" id="ContactUsPopulateState" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Submit Information" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="formSubmit" value="true">
				<input type="hidden" name="StateToPopulate" value="#URL.State#">
			<uForm:fieldset legend="Your Information">
				<uForm:field label="Your First Name" name="fName" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your First Name" />
				<uForm:field label="Your Last Name" name="lName" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your Last Name" />
				<uForm:field label="Your Email Address" name="EmailAddress" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your School's Email Address" />
				<uForm:field label="School Districts ZipCode" name="DistrictZipCode" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="School Districts ZipCode" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="5" />
			</uForm:fieldset>
			<uForm:fieldset legend="State Information">
				<uForm:field label="State to Populate" name="StateToPopulate" isRequired="true" isDisabled="true" maxFieldLength="50" type="text" value="#URL.State#" hint="State to Populate Information Within" />
			</uForm:fieldset>
		</uForm:form>
	</cfoutput>
<cfelseif isDefined("URL.FormRetry")>
	<cfoutput>
		<h2>Contact Us to Populate State Information</h2>
		<p class="alert-box notice">Please complete the following information to let us know the intent to populate a state with School Districts and School Buildings.</p>
		<hr>
		<uForm:form action="" method="Post" id="ContactUsPopulateState" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Submit Information" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="formSubmit" value="true">
				<input type="hidden" name="StateToPopulate" value="#Session.FormData.StateToPopulate#">
			<uForm:fieldset legend="Your Information">
				<uForm:field label="Your First Name" name="fName" isRequired="true" value="#Session.FormData.fName#" isDisabled="false" maxFieldLength="50" type="text" hint="Your First Name" />
				<uForm:field label="Your Last Name" name="lName" isRequired="true" value="#Session.FormData.lName#" isDisabled="false" maxFieldLength="50" type="text" hint="Your Last Name" />
				<uForm:field label="Your Email Address" name="EmailAddress" isRequired="true" value="#Session.FormData.EmailAddress#" isDisabled="false" maxFieldLength="50" type="text" hint="Your School's Email Address" />
				<uForm:field label="School Districts ZipCode" name="DistrictZipCode" isRequired="true" value="#Session.FormData.DistrictZipCode#" isDisabled="false" maxFieldLength="50" type="text" hint="School Districts ZipCode" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="5" />
			</uForm:fieldset>
			<uForm:fieldset legend="State Information">
				<uForm:field label="State to Populate" name="StateToPopulate" isRequired="true" value="#Session.FormData.StateToPopulate#" isDisabled="true" maxFieldLength="50" type="text" hint="State to Populate Information Within" />
			</uForm:fieldset>
		</uForm:form>
	</cfoutput>
</cfif>