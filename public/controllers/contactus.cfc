/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif isDefined("FORM.formSubmit")>
			<cfset Session.FormErrors = #ArrayNew()#>
			<cfset Session.FormData = #StructCopy(FOrm)#>
			<cfset Session.FormData.PluginInfo = StructNew()>
			<cfset Session.FormData.PluginInfo.Datasource = #rc.$.globalConfig('datasource')#>
			<cfset Session.FormData.PluginInfo.DBUserName = #rc.$.globalConfig('dbusername')#>
			<cfset Session.FormData.PluginInfo.DBPassword = #rc.$.globalConfig('dbpassword')#>
			<cfset Session.FormData.PluginInfo.PackageName = #HTMLEditFormat(rc.pc.getPackage())#>
			<cfset Session.FormData.PluginInfo.SiteID = #rc.$.siteConfig('siteID')#>

			<cfif #HASH(FORM.HumanChecker)# NEQ FORM.HumanCheckerhash>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Characters entered did not match what was displayed"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:contactus&FormRetry=True">
			</cfif>

			<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
			<cfset temp = #SendEmailCFC.SendStateToPopulateToAdmin(Session.FormData)#>
			<cflocation addtoken="true" url="/?SentInquiry=true&StateToPopulate=True">
		</cfif>
	</cffunction>

</cfcomponent>