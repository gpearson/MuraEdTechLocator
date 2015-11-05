<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2014 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfparam name="Session.FailedZipCodes" default="">
<cfoutput>
	<cfif isDefined("URL.Action") and isDefined("URL.ActionSuccessfull")>
		<cfswitch expression="#URL.Action#">
			<cfcase value="ImportSchoolBuildings">
				<cfswitch expression="#URL.ActionSuccessfull#">
					<cfcase value="True">
						<div class="alert-box success">
							<p>Your have successfully imported School Buildings for the State you selected.</p>
						</div>
					</cfcase>
				</cfswitch>
			</cfcase>
			<cfcase value="ImportSchoolDistricts">
				<cfswitch expression="#URL.ActionSuccessfull#">
					<cfcase value="True">
						<div class="alert-box success">
							<p>Your have successfully imported School Districts for the State you selected.</p>
						</div>
					</cfcase>
				</cfswitch>
			</cfcase>
		</cfswitch>
	</cfif>
	<h2>Home</h2>
	<p>Hello there! Welcome to the Home view of the FW/1's Main section.</p>
	<p>This is just a FW/1 sub-application. You could create your own admin interface here, or simply provide instructions on how to use your plugin. It's entirely up to you.</p>

	<ul>
		<li>Administrative Menu
			<UL>
				<li><a href="#buildurl('admin:utilities.importzipcodes')#">Import ZipCode Database</a></li>
				<li><a href="#buildurl('admin:utilities.importncespublicschooldistrictdata')#">Import NCES Public School District Data</a></li>
				<li><a href="#buildurl('admin:utilities.importncespublicschoolbuildingdata')#">Import NCES Public School Building Data</a></li>
			</UL>
		</li>
	</ul>
	<p><cfdump var="#Session.FailedZipCodes#"></p>
</cfoutput>