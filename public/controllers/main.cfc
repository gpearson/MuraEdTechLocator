/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfset Session.FormData = StructNew()>
		<cfset Session.FormData.PluginInfo = StructNew()>
		<cfset Session.FormData.PluginInfo.Datasource = #rc.$.globalConfig('datasource')#>
		<cfset Session.FormData.PluginInfo.DBUserName = #rc.$.globalConfig('dbusername')#>
		<cfset Session.FormData.PluginInfo.DBPassword = #rc.$.globalConfig('dbpassword')#>
		<cfset Session.FormData.PluginInfo.PackageName = #HTMLEditFormat(rc.pc.getPackage())#>
		<cfset Session.FormData.PluginInfo.SiteID = #rc.$.siteConfig('siteID')#>

	</cffunction>

</cfcomponent>