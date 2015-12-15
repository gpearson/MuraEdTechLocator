/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="activateaccount" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">
	</cffunction>

	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>

		<cfif isDefined("FORM.formSubmit") and not isDefined("URL.SelectDistrict")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormData.PluginInfo = StructNew()>
			<cfset Session.FormData.PluginInfo.Datasource = #rc.$.globalConfig('datasource')#>
			<cfset Session.FormData.PluginInfo.DBUserName = #rc.$.globalConfig('dbusername')#>
			<cfset Session.FormData.PluginInfo.DBPassword = #rc.$.globalConfig('dbpassword')#>
			<cfset Session.FormData.PluginInfo.PackageName = #HTMLEditFormat(rc.pc.getPackage())#>
			<cfset Session.FormData.PluginInfo.SiteID = #rc.$.siteConfig('siteID')#>
			<cfset Session.FormErrors = #ArrayNew()#>
			<cfset Session.FormData.UserInput = #StructCopy(FORM)#>


			<cfif FORM.formSubmit EQ "true" and not isDefined("URL.SelectDistrict")>
				<!--- Checks to make sure Captcha is entered correctly --->
				<cfif #HASH(FORM.HumanChecker)# NEQ FORM.HumanCheckerhash>
					<cfscript>
						HumanChecker = {property="HumanChecker",message="The CAPTCHA Characters were not correct in the image. Please enter the correct sequence of characters and submit this form again."};
						arrayAppend(Session.FormErrors, HumanChecker);
					</cfscript>
					<cflocation url="/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:registeruser.default&UserRegistrationSuccessfull=false" addtoken="false">
				</cfif>
			</cfif>

			<!--- Initiates the User Bean --->
			<cfset NewUser = #Application.userManager.readByUsername(form.Username, rc.$.siteConfig('siteID'))#>
			<cfset NewUser.setInActive(1)>
			<cfset NewUser.setSiteID(rc.$.siteConfig('siteID'))>
			<cfset NewUser.setFname(FORM.fName)>
			<cfset NewUser.setLname(FORM.lName)>
			<cfset NewUser.setUsername(FORM.UserName)>
			<cfset NewUser.setPassword(FORM.Password)>
			<cfset NewUser.setEmail(FORM.UserName)>

			<cfif NewUser.checkUsername() EQ "false">
				<!--- Username already exists within the database. --->
				<cfscript>
					UsernameExists = {property="UserName",message="The Email Address already exists within the database. If this Email Address is your account, you can request a forgot password by clicking on the Forgot Password Link under the Home Navigation Menu at the top of this screen. Otherwise please enter a different email address so your account can be created."};
					arrayAppend(Session.FormErrors, UsernameExists);
				</cfscript>
				<cflocation url="/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:registeruser.default&UserRegistrationSuccessfull=false" addtoken="false">
			</cfif>

			<cfif not isValid("email", FORM.UserName)>
				<cfscript>
					UsernameNotValid = {property="UserName",message="The Email Address is not a valid email address. We use this email address as the communication method to update you on your grant application."};
					arrayAppend(Session.FormErrors, UsernameNotValid);
				</cfscript>
				<cflocation url="/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:registeruser.default&UserRegistrationSuccessfull=false" addtoken="false">
			</cfif>

			<cfset AddNewAccount = #Application.userManager.save(NewUser)#>

			<cfif LEN(AddNewAccount.getErrors()) EQ 0>
				<cfset NewUserID = #AddNewAccount.getUserID()#>

				<cfquery name="insertUserMatrixInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Insert into pUserMatrix(User_ID,Site_ID,SchoolDistrict_ZipCode,LastUpdateBy,LastUpdated)
					 Values('#Variables.NewUserID#','#rc.$.siteConfig("siteID")#','FORM.DistrictZipCode',System',#Now()#)
				</cfquery>

				<cfset SendActivationEmail = #SendEmailCFC.SendAccountActivationEmail(Variables.NewUserID)#>


				<cflocation url="/index.cfm?UserRegistrationSuccessfull=true&UserAction=AccountCreated" addtoken="false">
			<cfelse>
				<cfdump var="#AddNewAccount.getErrors()#"><cfabort>
			</cfif>
		<cfelseif isDefined("FORM.formSubmit") and isDefined("URL.ServiceMarketEligible") and isDefined("URL.SelectDistrict") and isDefined("FORM.formCreateAccount")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormData.PluginInfo = StructNew()>
			<cfset Session.FormData.PluginInfo.Datasource = #rc.$.globalConfig('datasource')#>
			<cfset Session.FormData.PluginInfo.DBUserName = #rc.$.globalConfig('dbusername')#>
			<cfset Session.FormData.PluginInfo.DBPassword = #rc.$.globalConfig('dbpassword')#>
			<cfset Session.FormData.PluginInfo.PackageName = #HTMLEditFormat(rc.pc.getPackage())#>
			<cfset Session.FormData.PluginInfo.SiteID = #rc.$.siteConfig('siteID')#>
			<cfset Session.FormErrors = #ArrayNew()#>
			<cfset Session.FormData.UserInput = StructCopy(FORM)>

			<!--- Checks to make sure Captcha is entered correctly --->
			<cfif #HASH(FORM.HumanChecker)# NEQ FORM.HumanCheckerhash>
				<cfscript>
					HumanChecker = {property="HumanChecker",message="The CAPTCHA Characters were not correct in the image. Please enter the correct sequence of characters and submit this form again."};
					arrayAppend(Session.FormErrors, HumanChecker);
				</cfscript>
				<cflocation url="#rc.$.GrantApplication.buildURL('public:registeruser.default')#&ServiceMarketEligible=true&SelectDistrict=true&ReEnterForm=true" addtoken="false">
			</cfif>

			<cfif FORM.Password NEQ FORM.VerifyPassword>
				<cfscript>
					HumanChecker = {property="VerifyPassword",message="The Password and Verify Password Fields did not match. Please reenter your desired password"};
					arrayAppend(Session.FormErrors, HumanChecker);
				</cfscript>
				<cflocation url="#rc.$.GrantApplication.buildURL('public:registeruser.default')#&ServiceMarketEligible=true&SelectDistrict=true&ReEnterForm=true" addtoken="false">
			</cfif>



		</cfif>
	</cffunction>

</cfcomponent>