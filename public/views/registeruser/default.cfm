<cfimport taglib="/plugins/1To1TechLocator/library/uniForm/tags/" prefix="uForm">
<cfif not isDefined("URL.UserRegistrationSuccessfull")>
	<cflock timeout="60" scope="SESSION" type="Exclusive">
		<cfset Session.FormData = #StructNew()#>
		<cfset Session.FormErrors = #ArrayNew()#>
		<cfset Session.UserRegistrationInfo = #StructNew()#>
	</cflock>
	<cfoutput>
		<h2>Register new User Account</h2>
		<p class="alert-box notice">Please complete the following information to register for a user account on this website resource. All electric communications from this system will be sent to the email address you provide.</p>
		<hr>
		<uForm:form action="" method="Post" id="RegisterUser" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Create User Account" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="InActive" valule="1">
				<input type="hidden" name="formSubmit" value="true">
			<uForm:fieldset legend="User Account Fields">
				<uForm:field label="Your First Name" name="fName" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your First Name" />
				<uForm:field label="Your Last Name" name="lName" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your Last Name" />
				<uForm:field label="Your Email Address" name="UserName" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="Your School's Email Address" />
				<uForm:field label="Your Desired Password" name="Password" isRequired="true" isDisabled="false" maxFieldLength="50" type="password" hint="A Password to use on this site" />
				<uForm:field label="Confirm Desired Password" name="VerifyPassword" isRequired="true" isDisabled="false" maxFieldLength="50" type="password" hint="Confirm Password for Site" />
				<uForm:field label="School Districts ZipCode" name="DistrictZipCode" isRequired="true" isDisabled="false" maxFieldLength="50" type="text" hint="School Districts ZipCode" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="5" />
			</uForm:fieldset>
		</uForm:form>
	</cfoutput>
<cfelseif isDefined("URL.UserRegistrationSuccessfull")>
	<cfoutput>
		<h2>Register new User Account</h2>
		<p class="alert-box notice">Please complete the following information to register for a user account on this website resource. All electric communications from this system will be sent to the email address you provide.</p>
		<hr>
		<uForm:form action="" method="Post" id="RegisterUser" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Create User Account" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="InActive" valule="1">
				<input type="hidden" name="formSubmit" value="true">
			<uForm:fieldset legend="User Account Fields">
				<uForm:field label="Your First Name" name="fName" isRequired="true" value="#session.FormData.fName#" isDisabled="false" maxFieldLength="50" type="text" hint="Your First Name" />
				<uForm:field label="Your Last Name" name="lName" isRequired="true" value="#session.FormData.lName#" isDisabled="false" maxFieldLength="50" type="text" hint="Your Last Name" />
				<uForm:field label="Your Email Address" name="UserName" isRequired="true" isDisabled="false" value="#session.FormData.Username#" maxFieldLength="50" type="text" hint="Your School's Email Address" />
				<uForm:field label="Your Desired Password" name="Password" isRequired="true" isDisabled="false" maxFieldLength="50"  value="#session.FormData.Password#" type="password" hint="A Password to use on this site" />
				<uForm:field label="Confirm Desired Password" name="VerifyPassword" isRequired="true" isDisabled="false" maxFieldLength="50" type="password" hint="Confirm Password for Site" />
				<uForm:field label="School Districts ZipCode" name="DistrictZipCode" isRequired="true"  value="#session.FormData.DistrictZipCode#" isDisabled="false" maxFieldLength="50" type="text" hint="School Districts ZipCode" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="5" />
			</uForm:fieldset>
		</uForm:form>
	</cfoutput>
<cfelseif isDefined("URL.UserRegistrationSuccessfull") and isDefined("URL.SelectDistrict") and isDefined("URL.ZipCode")>
	<cfquery name="GetLatLongFromZipCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
		Select ZipCode, City, State, Latitude, Longitude
		From pZipCodes
		Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
			ZipCode = <cfqueryparam value="#URL.ZipCode#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="GetLatLongWithinDistanceFromZipCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
		SELECT ZipCode, City, State, Latitude, Longitude, ROUND((ACOS((SIN(#GetLatLongFromZipCode.Latitude#/57.2958) * SIN(Latitude/57.2958)) + (COS(#GetLatLongFromZipCode.Latitude#/57.2958) * COS(Latitude/57.2958) * COS(Longitude/57.2958 - #GetLatLongFromZipCode.Longitude#/57.2958)))) * 3963) AS distance
		FROM pZipCodes
		WHERE (Latitude >= #GetLatLongFromZipCode.Latitude# - (25/111))
			AND (Latitude <= #GetLatLongFromZipCode.Latitude# + (25/111))
			AND (Longitude >= #GetLatLongFromZipCode.Longitude# - (25/111))
			AND (Longitude <= #GetLatLongFromZipCode.Longitude# + (25/111))
		ORDER BY distance
	</cfquery>
	<cfset ZipCodesWithinRange = #ValueList(GetLatLongWIthinDistanceFromZipCode.ZipCode)#>

	<cfquery name="getSchoolDistrictsWithinSearch" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
		Select DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, NCES_ID
		From pSchoolDistricts
		Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
			PhysicalZipCode IN (#Variables.ZipCodesWithinRange#)
		Order by DistrictName
	</cfquery>

	<cfoutput>
		<h2>Select School Distirct</h2>
		<p class="alert-box notice">Please complete the following information to register for a user account on this event registration system. All electric communications from this system will be sent to the email address you provide. Any certificates that will be generated upon successfull completion of an event that issues certificates will use the information on this screen. Please make sure the information listed below is correct.</p>
		<hr>
		<uForm:form action="" method="Post" id="RegisterUser" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="no" cancelValue="<--- Return to Available Events" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Create User Account" loadValidation="true" loadMaskUI="true" loadDateUI="true" loadTimeUI="true">
				<input type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<input type="hidden" name="InActive" valule="1">
				<input type="hidden" name="formSubmit" value="true">
				<uForm:fieldset legend="User Account Fields">
					<uForm:field label="Your First Name" name="fName" isRequired="true" isDisabled="true" value="#Session.FormData.fName#" maxFieldLength="50" type="text" hint="Your First Name as you would like printed on certificates" />
					<uForm:field label="Your Last Name" name="lName" isRequired="true" isDisabled="true" value="#Session.FormData.lName#" maxFieldLength="50" type="text" hint="Your Last Name as you would like printed on certificates" />
					<uForm:field label="Your Email Address" name="UserName" isRequired="true" isDisabled="true" value="#Session.FormData.UserName#" maxFieldLength="50" type="text" hint="Your Primary Email Address" />
				</uForm:fieldset>
				<uForm:fieldset legend="Optional Fields">
					<uform:field label="School District" name="Company" type="select" hint="School District employeed at?">
						<uform:option display="Corporate Business" value="0000" isSelected="true" />
						<uform:option display="School District Not Listed" value="0001" isSelected="true" />
						<cfloop query="getSchoolDistrictsWithinSearch">
							<uform:option display="#getSchoolDistrictsWithinSearch.DistrictName#" value="#getSchoolDistrictsWithinSearch.NCES_ID#" />
						</cfloop>
					</uform:field>
					<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="8" />
				</uForm:fieldset>
		</uForm:form>
	</cfoutput>
</cfif>