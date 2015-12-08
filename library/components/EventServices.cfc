<cfcomponent displayName="Event Registration Routines">

	<cffunction name="QRCodeImage" ReturnType="String" output="False">
		<cfargument name="Data" type="string" Required="True">
		<cfargument name="PluginDirectory" type="string" Required="True">
		<cfargument name="QRCodeImageFilename" type="string" Required="True">

		<cfset qr = createObject("component","plugins/#Arguments.PluginDirectory#/library/components/QRCode")>
		<cfset CurLoc = #ExpandPath("/")#>
		<cfset FileStoreLoc = #Variables.CurLoc# & "plugins/" & #Arguments.PluginDirectory# & "/library/images/QRCodes">
		<cfset ImageFilename = #Arguments.QRCodeImageFilename# & ".png">
		<cfset FileWritePathWithName = #Variables.FileStoreLoc# & "/" & #Variables.ImageFilename#>
		<cfset URLFileLocation = "/plugins/" & #Arguments.PluginDirectory# & "/library/images/QRCodes/" & #Variables.ImageFilename#>
		<cffile action="write" file="#Variables.FileWritePathWithName#" output="#qr.getQRCode("#Arguments.Data#",100,100,"png")#">
		<cfreturn #Variables.URLFileLocation#>
	</cffunction>

	<cffunction name="BarcodeImage" ReturnType="String" output="False">
		<cfargument name="Data" type="string" Required="True">
		<cfargument name="PluginDirectory" type="string" Required="True">
		<cfargument name="BarcodeImageFilename" type="string" Required="True">

		<cfset RegistrationIDBarcode = createObject("component","plugins/#Arguments.PluginDirectory#/library/components/BarbecueService")>
		<cfset CurLoc = #ExpandPath("/")#>
		<cfset FileStoreLoc = #Variables.CurLoc# & "plugins/" & #Arguments.PluginDirectory# & "/library/images/BarCodeTemp">
		<cfset ImageFilename = #Arguments.BarcodeImageFilename# & ".jpg">
		<cfset FileWritePathWithName = #Variables.FileStoreLoc# & "/" & #Variables.ImageFilename#>
		<cfset URLFileLocation = "/plugins/" & #Arguments.PluginDirectory# & "/library/images/BarCodeTemp/" & #Variables.ImageFilename#>
		<cffile action="write" file="#Variables.FileWritePathWithName#" output="#RegistrationIDBarcode.barcodeToBrowser(Arguments.Data)#">
		<cfreturn #Variables.URLFileLocation#>
	</cffunction>

	<cffunction name="GetLatitudeLongitudeProximity" ReturnType="Numeric" output="False">
		<cfargument name="FromLatitude" type="numeric" required="true" hint="I am the starting Latitude Value">
		<cfargument name="FromLongitude" type="numeric" required="true" hint="I am the starting Longitude Value">
		<cfargument name="ToLatitude" type="numeric" required="true" hint="I am the ending Latitude Value">
		<cfargument name="ToLongitude" type="numeric" required="true" hint="I am the ending Longitude Value">

		<cfset var LOCAL = {}>
		<cfset LOCAL.MilesPerLatitude = 69.09>
		<cfset LOCAL.DegreeDistance = RadiansToDegrees(
			ACos(
				Sin(DegreesToRadians(Arguments.FromLatitude)) * Sin(DegreesToRadians(Arguments.ToLatitude))
			)
			+
			(
				COS(DegreesToRadians(Arguments.FromLatitude)) * Cos(DegreesToRadians(Arguments.ToLatitude)) * COS(DegreesToRadians(Arguments.ToLongitude - Arguments.FromLognitude))
			)
		) />
		cfreturn Round(Local.DegreeDistance * LOCAL.MilesPerLatitude) />
	</cffunction>

	<cffunction name="DegreesToRadians" returntype="numeric" output="false" hint="I convert degrees to radians.">
		<cfargument name="Degrees" type="numeric" required="true" hint="I am the degree value to be converted to radians.">
		<cfreturn (Arguments.Degrees * PI() / 180) />
	</cffunction>

	<cffunction name="RadiansToDegrees" returntype="numeric" output="false" hint="I convert radians to degrees">
		<cfargument name="Radians" type="numeric" required="true" hint="I am the radian value to be converted to degrees.">
		<cfreturn (Arguments.Radians * 180 / PI()) />
	</cffunction>

	<cffunction name="iCalUS" returntype="String" output="false" hint="Create iCal Event for Registered Users">
		<cfargument name="RegistrationRecordID" required="true" type="numeric">

		<cfquery name="getRegistration" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select RegistrationID, RegistrationDate, User_ID, EventID, RequestsMeal, IVCParticipant, AttendeePrice, RegisterByUserID, OnWaitingList, Comments, WebinarParticipant
			From eRegistrations
			Where TContent_ID = <cfqueryparam value="#Arguments.RegistrationRecordID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="getEvent" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select ShortTitle, EventDate, EventDate1, EventDate2, EventDate3, EventDate4, LongDescription, Event_StartTime, Event_EndTime, PGPPoints, MealProvided, AllowVideoConference, VideoConferenceInfo, EventAgenda, EventTargetAudience, EventStrategies, EventSpecialInstructions, LocationType, LocationID, LocationRoomID, Facilitator, WebinarAvailable, WebinarConnectInfo, WebinarMemberCost, WebinarNonMemberCost
			From eEvents
			Where TContent_ID = <cfqueryparam value="#getRegistration.EventID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="getEventLocation" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select FacilityName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude
			From eFacility
			Where FacilityType = '#getEvent.LocationType#' and TContent_ID = #getEvent.LocationID#
		</cfquery>

		<cfquery name="getRegisteredUserInfo" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select Fname, Lname, Email
			From tusers
			Where UserID = <cfqueryparam value="#getRegistration.User_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getEventFacilitator" Datasource="#Session.FormData.PluginInfo.Datasource#" username="#Session.FormData.PluginInfo.DBUsername#" password="#Session.FormData.PluginInfo.DBPassword#">
			Select Fname, Lname, Email
			From tusers
			Where UserID = <cfqueryparam value="#getEvent.Facilitator#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset CRLF = #chr(13)# & #chr(10)#>
		<cfset CurrentDateTime = #Now()#>
		<cfset stEvent = StructNew()>
		<cfset stEvent.FacilitatorName = #getEventFacilitator.Fname# & " " & #getEventFacilitator.Lname#>
		<cfset stEvent.FacilitatorEmail = #getEventFacilitator.Email#>
		<cfset stEvent.EventLocation = #getEventLocation.FacilityName# & " (" & #getEventLocation.PhysicalAddress# & " " & #getEventLocation.PhysicalCity# & ", " & #getEventLocation.PhysicalState# & " " & #getEventLocation.PhysicalZipCode# & ")">
		<cfset stEvent.EventDescription = #getEvent.LongDescription# & "\n\n" & "Special Instructions:\n" & #getEvent.EventSpecialInstructions#>
		<cfset stEvent.Priority = 1>

		<cfset vCal = "BEGIN:VCALENDAR" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "PRODID: -//Northern Indiana ESC//Event Registration System//EN" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "VERSION:2.0" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "METHOD:REQUEST" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "BEGIN:VTIMEZONE" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZID:Eastern Time" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "BEGIN:STANDARD" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "DTSTART:20061101T020000" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=1SU;BYMONTH=11" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZOFFSETFROM:-0400" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZOFFSETTO:-0500" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZNAME:Standard Time" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "END:STANDARD" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "BEGIN:DAYLIGHT" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "DTSTART:20060301T020000" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=2SU;BYMONTH=3" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZOFFSETFROM:-0500" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZOFFSETTO:-0400" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TZNAME:Daylight Savings Time" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "END:DAYLIGHT" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "END:VTIMEZONE" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "BEGIN:VEVENT" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "UID:" & #getRegistration.RegistrationID# & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "ORGANIZER;CN=:" & #stEvent.FacilitatorName# & ":MAILTO:" & #stEvent.FacilitatorEmail# & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "DTSTAMP:" & #DateFormat(Now(), "yyyymmdd")# & "T" & TimeFormat(Now(), "HHmmss") & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "DTSTART;TZID=Eastern Time:" & #DateFormat(getEvent.EventDate, "yyyymmdd")# & "T" & TimeFormat(getEvent.Event_StartTime, "HHmmss") & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "DTEND;TZID=Eastern Time:" & #DateFormat(getEvent.EventDate, "yyyymmdd")# & "T" & TimeFormat(getEvent.Event_EndTime, "HHmmss") & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "SUMMARY:" & #getEvent.ShortTitle# & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "LOCATION:" & #stEvent.EventLocation# & #Variables.CRLF#>
		<cfif getRegistration.WebinarParticipant EQ 0>
			<cfset vCal = #Variables.vCal# & "DESCRIPTION:" & #stEvent.EventDescription# & #Variables.CRLF#>
		<cfelseif getRegistration.WebinarParticipant EQ 1 AND getEvent.WebinarAvailable EQ 1>
			<cfset vCal = #Variables.vCal# & "DESCRIPTION:" & #stEvent.EventDescription# & #Variables.CRLF#>
			<cfset vCal = #Variables.vCal# & "Webinar Information: " & #getEvent.WebinarConnectInfo# & #Variables.CRLF#>
		</cfif>
		<cfset vCal = #Variables.vCal# & "PRIORITY:" & #stEvent.Priority# & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "TRANSP:OPAQUE" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "CLASS:PUBLIC" & #Variables.CRLF#>
		<!---
			For a Reminder Use the Below Lines
			<cfset vCal = #Variables.vCal# & "BEGIN:VALARM" & #Variables.CRLF#>
			<cfset vCal = #Variables.vCal# & "TRIGGER:-PT30M" & #Variables.CRLF#>
			<cfset vCal = #Variables.vCal# & "ACTION:DISPLAY" & #Variables.CRLF#>
			<cfset vCal = #Variables.vCal# & "DESCRIPTION:Reminder" & #Variables.CRLF#>
			<cfset vCal = #Variables.vCal# & "END:VALARM" & #Variables.CRLF#>

		--->
		<cfset vCal = #Variables.vCal# & "END:VEVENT" & #Variables.CRLF#>
		<cfset vCal = #Variables.vCal# & "END:VCALENDAR" & #Variables.CRLF#>
		<cfreturn Trim(variables.vcal)>
	</cffunction>

	<cffunction name="GeoCodeAddress" ReturnType="Array" Output="False">
		<cfargument name="Address" type="String" required="True">
		<cfargument name="City" type="String" required="True">
		<cfargument name="State" type="String" required="True">
		<cfargument name="ZipCode" type="String" required="True">

		<cfset GeoCodeStreetAddress = #Replace(Trim(Arguments.Address), " ", "+", "ALL")#>
		<cfset GeoCodeCity = #Replace(Trim(Arguments.City), " ", "+", "ALL")#>
		<cfset GeoCodeState = #Replace(Trim(Arguments.State), " ", "+", "ALL")#>
		<cfset GeoCodeZipCode = #Trim(Arguments.ZipCode)#>

		<cfset GeoCodeAddress = ArrayNew(1)>
		<cfset Temp = StructNew()>

		<cfhttp URL="http://maps.google.com/maps/api/geocode/xml?address=#Variables.GeoCodeStreetAddress#,+#Variables.GeoCodeCity#,+#Variables.GeoCodeState#,+#Variables.GeoCodeZipCode#&sensor=false" method="Get" result="GetCodePageContent" resolveurl="true"></cfhttp>

		<cfif GetCodePageContent.FileContent Contains "REQUEST_DENIED">
			<cfset Temp.ErrorMessage = "Google Request Denied">
			<cfset Temp.AddressStreetNumber = "">
			<cfset Temp.AddressStreetName = "">
			<cfset Temp.AddressCityName = "">
			<cfset Temp.AddressStateNameLong = "">
			<cfset Temp.AddressStateNameShort = "">
			<cfset Temp.AddressZipCode = "">
			<cfset Temp.AddressTownshipName = "">
			<cfset Temp.AddressNeighborhoodName = "">
			<cfset Temp.AddressCountyName = "">
			<cfset Temp.AddressCountryNameLong = "">
			<cfset Temp.AddressCountryNameShort = "">
			<cfset Temp.AddressLatitude = "">
			<cfset Temp.AddressLongitude = "">
			<cfset #arrayAppend(GeoCodeAddress, Temp)#>
		</cfif>

		<cfset XMLDocument = #XMLParse(GetCodePageContent.FileContent)#>
		<cfset GeoCodeResponseStatus = #XMLSearch(Variables.XMLDocument, "/GeocodeResponse/status")#>
		<cfset GeoCodeResultFormattedAddressType = #XmlSearch(Variables.XMLDocument, "/GeocodeResponse/result/type")#>
		<cfset GeoCodeResultFormattedAddress = #XmlSearch(Variables.XMLDocument, "/GeocodeResponse/result/formatted_address")#>
		<cfset GeoCodeResultAddressComponent = #XMLSearch(Variables.XMLDocument, "/GeocodeResponse/result/address_component")#>
		<cfset GeoCodeResultGeometryComponent = #XMLSearch(XMLDocument, "/GeocodeResponse/result/geometry")#>

		<cfswitch expression="#GeoCodeResponseStatus[1].XMLText#">
			<cfcase value="ZERO_RESULTS">
				<!--- Indicates that the geocode was successful but returned no results. This may occur if the geocode was passed a non-existent address
						or latlng in a remote location --->
			</cfcase>
			<cfcase value="OVER_QUERY_LIMIT">
				<!--- Indicates that you are over your quota --->
			</cfcase>
			<cfcase value="REQUEST_DENIED">
				<!--- Indicates that your request was denied, generally becasue of lack of a sensor parameter --->
			</cfcase>
			<cfcase value="INVALID_REQUEST">
				<!--- generally indicates that the query (address or latlng) is missing --->
			</cfcase>
			<cfcase value="UNKNOWN_ERROR">
				<!--- Indicates that the request could not be processed do to a server error. The request may sicceed if you try again --->
			</cfcase>
			<cfcase value="OK">
				<cfswitch expression="#GeoCodeResultFormattedAddressType[1].XMLText#">
					<cfcase value="route">
						<cfset Temp.ErrorMessage = "Unable Locate Address">
						<cfset Temp.ErrorMessageText = "Unable to locate the address you entered as a valid address.">
						<cfset Temp.Address = #Arguments.Address#>
						<cfset Temp.City = #Arguments.City#>
						<cfset Temp.State = #Arguments.State#>
						<cfset Temp.ZipCode = #Arguments.ZipCode#>
						<cfset #arrayAppend(GeoCodeAddress, Temp)#>
						<cfreturn GeoCodeAddress>
					</cfcase>
					<cfcase value="street_address">
						<cfswitch expression="#ArrayLen(GeoCodeResultAddressComponent)#">
							<cfdefaultcase>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.ArrayLength = #ArrayLen(GeoCodeResultAddressComponent)#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfdefaultcase>
							<cfcase value="8">
								<!--- Address Example: 410 N 1st Street, Argos, IN  --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									// GeoCodeResultNeighborhoodName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultTownshipName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[8].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.ArrayLength = #ArrayLen(GeoCodeResultAddressComponent)#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfcase>
							<cfcase value="9">
								<!--- Address Example: 4900 W 15th Ave, Gary, IN 46406 --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									// GeoCodeResultNeighborhoodName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultTownshipName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[8].XmlChildren;
									GeoCodeResultZipPlusFour = GeoCodeResultAddressComponent[9].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.ArrayLength = #ArrayLen(GeoCodeResultAddressComponent)#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressZipCodePlusFour = #GeoCodeResultZipPlusFour[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfcase>
							<!---
							<cfdefaultcase>
								<!--- Address Example: 2307 Edison Road, South Bend, IN 46615 --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>

								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset Temp.AddressTownshipNameLong = "">
								<cfset Temp.AddressTownshipNameShort = "">
								<cfset Temp.NeighborhoodNameLong = "">
								<cfset Temp.NeighborhoodNameShort = "">
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfdefaultcase> --->
						</cfswitch>
					</cfcase>
					<cfcase value="postal_code">
						<cfset Temp.ErrorMessage = "Unable Locate Address">
						<cfset Temp.ErrorMessageText = "Unable to locate the address you entered as a valid address.">
						<cfset Temp.Address = #Arguments.Address#>
						<cfset Temp.City = #Arguments.City#>
						<cfset Temp.State = #Arguments.State#>
						<cfset Temp.ZipCode = #Arguments.ZipCode#>
						<cfset #arrayAppend(GeoCodeAddress, Temp)#>
						<cfreturn GeoCodeAddress>
					</cfcase>
					<cfdefaultcase>
						<cfoutput>#GeoCodeResultFormattedAddressType[1].XMLText#</cfoutput><hr>
						<cfdump var="#XMLDocument#">
						<cfdump var="#GeoCodeResponseStatus#">
						<cfdump var="#GeoCodeResultFormattedAddressType#">
						<cfdump var="#GeoCodeResultFormattedAddress#">
						<cfabort>
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
		</cfswitch>
		<cfreturn GeoCodeAddress>
	</cffunction>

</cfcomponent>