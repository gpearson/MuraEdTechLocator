<cfcomponent displayName="Event Registration Email Routines">

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