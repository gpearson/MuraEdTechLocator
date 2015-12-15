<cfimport taglib="/plugins/1To1TechLocator/library/uniForm/tags/" prefix="uForm">
<cfif not isDefined("Session.FormData")>
	<cflock scope="Session" timeout="60" type="Exclusive">
		<cfset Session.FormData = #StructNew()#>
	</cflock>
</cfif>
<cfoutput>
	<cfif not isDefined("URL.FormRetry")>
		<cfset Session.FormErrors = #ArrayNew()#>
		<cfquery name="getAccountDetails" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			SELECT pUserMatrix.School_District, pUserMatrix.SchoolDistrict_ZipCode, tusers.Fname, tusers.MobilePhone,
				tusers.Lname, tusers.UserID, tusers.UserName, tusers.Email, tusers.Company, tusers.JobTitle
				FROM tusers INNER JOIN pUserMatrix ON pUserMatrix.User_ID = tusers.UserID
			Where UserID = <cfqueryparam value="#Session.Mura.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getZipCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select City, State, Latitude, Longitude
			From pZipCodes
			Where ZipCode = <cfqueryparam value="#getAccountDetails.SchoolDistrict_ZipCode#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getSchoolDistricts" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select DistrictName, NCES_ID, ROUND((ACOS((SIN(#getZipCode.Latitude#/57.2958) * SIN(GeoCode_Latitude/57.2958)) + (COS(#getZipCode.Latitude#/57.2958) * COS(GeoCode_Latitude/57.2958) * COS(GeoCode_Longitude/57.2958 - #getZipCode.Longitude#/57.2958)))) * 3963) AS distance
			From pSchoolDistricts
			Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
				(GeoCode_Latitude BETWEEN (#getZipCode.Latitude# - (25/111)) AND (#getZipCode.Latitude# + (25/111)))
				AND (GeoCode_Longitude BETWEEN (#getZipCode.Longitude# - (25/111)) AND (#getZipCode.Longitude# + (25/111)))
			Order by DistrictName
		</cfquery>

		<h2>Update Account Profile</h2>
		<p class="alert-box notice">Please complete the following information to update your account profile.</p>
		<hr>
		<uForm:form action="" method="Post" id="EditProfile" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="yes" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Update Profile" loadValidation="true" loadMaskUI="true" loadDateUI="false" loadTimeUI="false">
			<input type="hidden" name="formSubmit" value="true">
			<input type="hidden" name="UserID" value="#Session.Mura.UserID#">
			<uForm:fieldset legend="Required Fields">
				<uForm:field label="Account First Name" name="Fname" value="#Session.Mura.Fname#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The First Name of the Account Holder" />
				<uForm:field label="Account Last Name" name="Lname" value="#Session.Mura.Lname#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The Last Name of the Account Holder" />
				<uForm:field label="Account Email" name="Email" value="#Session.Mura.Email#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The Email Address of the Account Holder" />
				<uForm:field label="Account Username" name="Username" value="#Session.Mura.Username#" isRequired="False" isDisabled="True" maxFieldLength="50" type="text" hint="The Username of the Account Holder" />
			</uForm:fieldset>
			<uForm:fieldset legend="Optional Fields">
				<uform:field label="School District" name="Company" type="select" hint="School District employeed at?">
					<cfif Session.Mura.Company EQ "Corporate Business">
						<uform:option display="Corporate Business" value="0000" isSelected="true" />
					<cfelse>
						<uform:option display="Corporate Business" value="0000" />
					</cfif>
					<cfif Session.Mura.Company EQ "School District Not Listed">
						<uform:option display="School District Not Listed" value="0001" isSelected="true"  />
					<cfelse>
						<uform:option display="School District Not Listed" value="0001"  />
					</cfif>

					<cfloop query="getSchoolDistricts">
						<cfif Session.Mura.Company EQ getSchoolDistricts.DistrictName>
							<uform:option display="#getSchoolDistricts.DistrictName#" value="#getSchoolDistricts.NCES_ID#" isSelected="true" />
						<cfelse>
							<uform:option display="#getSchoolDistricts.DistrictName#" value="#getSchoolDistricts.NCES_ID#" />
						</cfif>
					</cfloop>
				</uform:field>
				<uForm:field label="Job Title" name="JobTitle" type="text" value="#getAccountDetails.JobTitle#" isRequired="False" isDisabled="False" maxFieldLength="50" hint="Your current Job Title" />
				<uForm:field label="Phone Number" name="mobilePhone" type="text" value="#getAccountDetails.mobilePhone#" maxFieldLength="14" isRequired="False" isDisabled="False" mask="(999) 999-9999" hint="Your contact number in case of cancellation of event during extreme sitations" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="8" />
			</uForm:fieldset>
		</uForm:form>
	<cfelseif isDefined("URL.FormRetry")>
		<cfquery name="getAccountDetails" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			SELECT pUserMatrix.School_District, pUserMatrix.SchoolDistrict_ZipCode, tusers.Fname, tusers.MobilePhone,
				tusers.Lname, tusers.UserID, tusers.UserName, tusers.Email, tusers.Company, tusers.JobTitle
				FROM tusers INNER JOIN pUserMatrix ON pUserMatrix.User_ID = tusers.UserID
			Where UserID = <cfqueryparam value="#Session.Mura.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getZipCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select City, State, Latitude, Longitude
			From pZipCodes
			Where ZipCode = <cfqueryparam value="#getAccountDetails.SchoolDistrict_ZipCode#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getSchoolDistricts" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select DistrictName, NCES_ID, ROUND((ACOS((SIN(#getZipCode.Latitude#/57.2958) * SIN(GeoCode_Latitude/57.2958)) + (COS(#getZipCode.Latitude#/57.2958) * COS(GeoCode_Latitude/57.2958) * COS(GeoCode_Longitude/57.2958 - #getZipCode.Longitude#/57.2958)))) * 3963) AS distance
			From pSchoolDistricts
			Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
				(GeoCode_Latitude BETWEEN (#getZipCode.Latitude# - (25/111)) AND (#getZipCode.Latitude# + (25/111)))
				AND (GeoCode_Longitude BETWEEN (#getZipCode.Longitude# - (25/111)) AND (#getZipCode.Longitude# + (25/111)))
			Order by DistrictName
		</cfquery>

		<h2>Update Account Profile</h2>
		<p class="alert-box notice">Please complete the following information to update your account profile.</p>
		<hr>
		<uForm:form action="" method="Post" id="EditProfile" errors="#Session.FormErrors#" errorMessagePlacement="both" commonassetsPath="/plugins/1To1TechLocator/library/uniForm/"
			showCancel="yes" cancelValue="<--- Return to Main Page" cancelName="cancelButton" cancelAction="/index.cfm"
			submitValue="Update Profile" loadValidation="true" loadMaskUI="true" loadDateUI="false" loadTimeUI="false">
			<input type="hidden" name="formSubmit" value="true">
			<input type="hidden" name="UserID" value="#Session.Mura.UserID#">
			<uForm:fieldset legend="Required Fields">
				<uForm:field label="Account First Name" name="Fname" value="#Session.Mura.Fname#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The First Name of the Account Holder" />
				<uForm:field label="Account Last Name" name="Lname" value="#Session.Mura.Lname#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The Last Name of the Account Holder" />
				<uForm:field label="Account Email" name="Email" value="#Session.Mura.Email#" isRequired="True" isDisabled="False" maxFieldLength="50" type="text" hint="The Email Address of the Account Holder" />
				<uForm:field label="Account Username" name="Username" value="#Session.Mura.Username#" isRequired="False" isDisabled="True" maxFieldLength="50" type="text" hint="The Username of the Account Holder" />
			</uForm:fieldset>
			<uForm:fieldset legend="Optional Fields">
				<uform:field label="School District" name="Company" type="select" hint="School District employeed at?">
					<cfif Session.Mura.Company EQ "Corporate Business">
						<uform:option display="Corporate Business" value="0000" isSelected="true" />
					<cfelse>
						<uform:option display="Corporate Business" value="0000" />
					</cfif>
					<cfif Session.Mura.Company EQ "School District Not Listed">
						<uform:option display="School District Not Listed" value="0001" isSelected="true"  />
					<cfelse>
						<uform:option display="School District Not Listed" value="0001"  />
					</cfif>

					<cfloop query="getSchoolDistricts">
						<cfif Session.Mura.Company EQ getSchoolDistricts.DistrictName>
							<uform:option display="#getSchoolDistricts.DistrictName#" value="#getSchoolDistricts.NCES_ID#" isSelected="true" />
						<cfelse>
							<uform:option display="#getSchoolDistricts.DistrictName#" value="#getSchoolDistricts.NCES_ID#" />
						</cfif>
					</cfloop>
				</uform:field>
				<uForm:field label="Job Title" name="JobTitle" type="text" value="#getAccountDetails.JobTitle#" isRequired="False" isDisabled="False" maxFieldLength="50" hint="Your current Job Title" />
				<uForm:field label="Phone Number" name="mobilePhone" type="text" value="#getAccountDetails.mobilePhone#" maxFieldLength="14" isRequired="False" isDisabled="False" mask="(999) 999-9999" hint="Your contact number in case of cancellation of event during extreme sitations" />
				<uform:field name="HumanChecker" isRequired="true" label="Please enter the characters you see below" type="captcha" captchaWidth="800" captchaMinChars="5" captchaMaxChars="8" />
			</uForm:fieldset>
		</uForm:form>
	</cfif>
</cfoutput>