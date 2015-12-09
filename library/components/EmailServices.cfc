<cfcomponent displayName="Event Registration Email Routines">

	<cffunction name="SendAccountActivationEmailConfirmation" returntype="Any" Output="false">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<!--- Setup Available Alphanumeric Values --->
		<cfset strLowerCaseAlpha = "abcdefghijlkmnopqrstuvwxyz">
		<cfset strUpperCaseAlpha = UCase(variables.strLowerCaseAlpha)>
		<cfset strNumbers = "01234567890">
		<cfset strOtherCharacters = "~!@$%^&*()-+">
		<cfset strAllValidCharacters = #variables.strLowerCaseAlpha# & #variables.strUpperCaseAlpha# & #variables.strNumbers# & #variables.strOtherCharacters#>
		<cfset arrPassword = ArrayNew(1)>
		<cfset arrPassword[1] = #Mid(variables.strNumbers, RandRange(1, Len(variables.strNumbers)), 1)#>
		<cfset arrPassword[2] = #Mid(variables.strLowerCaseAlpha, RandRange(1, Len(variables.strLowerCaseAlpha)), 1)#>
		<cfset arrPassword[3] = #Mid(variables.strUpperCaseAlpha, RandRange(1, Len(variables.strUpperCaseAlpha)), 1)#>

		<cfloop index="initChar" from="#(ArrayLen(arrPassword) + 1)#" to="8" step="1">
			<cfset arrPassword[initChar] = #Mid(variables.strAllValidCharacters, RandRange(1, Len(variables.strAllValidCharacters)), 1)#>
		</cfloop>

		<!--- Now that we have an array that has the proper number of characters, lets shuffle the array into a random order --->
		<cfset CreateObject("java", "java.util.Collections").Shuffle(variables.arrPassword)>

		<!--- Now we have a randomly suffled array, we just need to join all the characters into a single string. --->
		<cfset strPassword = #ArrayToList(variables.arrPassword, "")#>

		<cfinclude template="EmailTemplates/AccountActivationConfirmationEmailToIndividual.cfm">
	</cffunction>


	<cffunction name="SendAccountActivationEmail" returntype="Any" Output="false">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar"> and
				InActive = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
		</cfquery>

		<cfset ValueToEncrypt = "UserID=" & #Arguments.UserID# & "&" & "Created=" & #getUserAccount.created# & "&DateSent=" & #Now()#>
		<cfset EncryptedValue = #Tobase64(Variables.ValueToEncrypt)#>
		<cfset AccountVars = "Key=" & #Variables.EncryptedValue#>
		<cfset AccountActiveLink = "http://" & #CGI.Server_Name# & "/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:registeruser.activateaccount&" & #Variables.AccountVars#>

		<cfinclude template="EmailTemplates/SendAccountActivationEmailToIndividual.cfm">
	</cffunction>

	<cffunction name="SendStateToPopulateToAdmin" ReturnType="Any" Output="True">
		<cfargument name="EmailInfo" type="struct" Required="True">

		<cfquery name="getAdminGroup" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select Email
			From tusers
			Where SiteID = <cfqueryparam value="default" cfsqltype="cf_sql_varchar"> and
				UserName = <cfqueryparam value="admin" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfinclude template="EmailTemplates/PopulateStateInquiryToAdmin.cfm">
	</cffunction>

</cfcomponent>