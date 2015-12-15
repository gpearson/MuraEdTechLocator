<cfif not isDefined("URL.EventID") and Session.Mura.IsLoggedIn EQ "True">

<cfelseif Session.Mura.IsLoggedIn EQ "False" and isDefined("URL.EventID")>

</cfif>
