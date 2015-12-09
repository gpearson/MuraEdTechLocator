/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent extends="controller" output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">
	</cffunction>

	<cffunction name="CSVToQuery" access="public" returntype="query" output="false" hint="Converts the given CSV string to a query.">
		<!--- Define arguments. --->
		<cfargument name="CSV" type="string" required="true" hint="This is the CSV string that will be manipulated." />
		<cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value." />
		<cfargument name="Qualifier" type="string" required="false" default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded." />

		<!--- Define the local scope. --->
		<cfset var LOCAL = StructNew() />

		<!---
			When accepting delimiters, we only want to use the first character that we were passed. This is different than standard ColdFusion, but I am trying to make this as easy as possible.
		--->
		<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />

		<!---
			When accepting the qualifier, we only want to accept the first character returned. Is is possible that there is no qualifier being used. In that case, we can just store the empty string (leave as-is).
		--->
		<cfif Len( ARGUMENTS.Qualifier )><cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) /></cfif>

		<!---
			Set a variable to handle the new line. This will be the character that acts as the record delimiter.
		--->
		<cfset LOCAL.LineDelimiter = Chr( 10 ) />

		<!---
			We want to standardize the line breaks in our CSV value. A "line break" might be a return followed by a feed or just a line feed. We want to standardize it so that it is just a line feed. That way, it is easy to check for later (and it is a single character which makes our
			life 1000 times nicer).
		--->
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />


		<!---
			Let's get an array of delimiters. We will need this when we are going throuth the tokens and building up field values. To do this, we are going to strip out all
			characters that are NOT delimiters and then get the character array of the string. This should put each delimiter at it's own index.
		--->
		<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray() />

		<!---
			Add a blank space to the beginning of every theoretical field. This will help in make sure that ColdFusion / Java does not skip over any fields simply because they
			do not have a value. We just have to be sure to strip out this space later on. First, add a space to the beginning of the string.
		--->
		<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />

		<!--- Now add the space to each field. --->
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />

		 <!--- Break the CSV value up into raw tokens. Going forward, some of these tokens may be merged, but doing it this
		 	way will help us iterate over them. When splitting the string, add a space to each token first to ensure that
		 	the split works properly. BE CAREFUL! Splitting a string into an array using the Java String::Split method does not create a COLDFUSION
		 	ARRAY. You cannot alter this array once it has been created. It can merely be referenced (read only).
		 	We are splitting the CSV value based on the BOTH the field delimiter and the line delimiter. We will handle
		 	this later as we build values (this is why we created the array of delimiters above).
		 --->
		 <cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />

		 <!---
		 	Set up the default records array. This will be a full array of arrays, but for now, just create the parent
		 	array with no indexes.
		 --->
		 <cfset LOCAL.Rows = ArrayNew( 1 ) />

		 <!---
		 	Create a new active row. Even if we don't end up adding any values to this row, it is going to make our lives
		 	more smiple to have it in existence.
		 --->

		 <cfset ArrayAppend(LOCAL.Rows, ArrayNew( 1 ) ) />

		 <!---
		 	Set up the row index. THis is the row to which we are actively adding value.
		 --->
		 <cfset LOCAL.RowIndex = 1 />

		 <!---
		 	Set the default flag for wether or not we are in the middle of building a value across raw tokens.
		 --->
		 <cfset LOCAL.IsInValue = false />

		 <!---
		 	Loop over the raw tokens to start building values. We have no sense of any row delimiters yet. Those will
		 	have to be checked for as we are building up each value.
		 --->
		 <cfloop index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
			 <!---
			 	Get the current field index. This is the current index of the array to which we might be appending
			 	values (for a multi-token value).
			 --->
			 <cfset LOCAL.FieldIndex = ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) />

			 <!---
			 	Get the next token. Trim off the first character which is the empty string that we added to ensure
			 	proper splitting.
			 --->
			 <cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst( "^.{1}", "" ) />

			 <!---
			 	Check to see if we have a field qualifier. If we do, then we might have to build the value across
			 	multiple fields. If we do not, then the raw tokens should line up perfectly with the real tokens.
			 --->
			 <cfif Len( ARGUMENTS.Qualifier )>
			 	<!---
			 		Check to see if we are currently building a field value that has been split up among different delimiters.
			 	--->
			 	<cfif LOCAL.IsInValue>
			 		<!---
			 			ASSERT: Since we are in the middle of building up a value across tokens, we can
			 			assume that our parent FOR loop has already executed at least once. Therefore, we can
			 			assume that we have a previous token value ALREADY in the row value array and that we
			 			have access to a previous delimiter (in our delimiter array).
			 		--->

			 		<!---
			 			Since we are in the middle of building a value, we replace out double qualifiers with
			 			a constant. We don't care about the first qualifier as it can ONLY be an escaped
			 			qualifier (not a field qualifier).
			 		--->
			 		<cfset LOCAL.Token = LOCAL.Token.ReplaceAll( "\#ARGUMENTS.Qualifier#{2}", "{QUALIFIER}" ) />

			 		<!---
			 			Add the token to the value we are building. While this is not easy to read, add it
			 			directly to the results array as this will allow us to forget about it later. Be sure
			 			to add the PREVIOUS delimiter since it is actually an embedded delimiter character
			 			(part of the whole field value).
			 		--->
			 		<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = ( LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] & LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token ) />

			 		 <!---
			 		 	Now that we have removed the possibly escaped qualifiers, let's check to see if this field is ending a multi-token
			 		 	qualified value (its last character is a field qualifier).
			 		 --->
			 		 <cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>

				 	<!---
				 		Wooohoo! We have reached the end of a qualified value. We can complete this value and move onto the next field.
				 		Remove the trailing quote. Remember, we have already added to token to the results array so we must now
				 		manipulate the results array directly. Any changes made to LOCAL.Token at this point will not affect the results.
				 	--->
				 	<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />

				 	<!---
				 		Set the flag to indicate that we are no longer building a field value across tokens.
				 	--->
				 	<cfset LOCAL.IsInValue = false />
				</cfif>
			<cfelse>
				<!---
					We are NOT in the middle of building a field value which means that we have to be careful of a few special token cases:
						1. The field is qualified on both ends.
						2. The field is qualified on the start end.
				--->

				<!---
					Check to see if the beginning of the field is qualified. If that is the case then either
					this field is starting a multi-token value OR this field has a completely qualified value.
				--->
				<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
					<!---
						Delete the first character of the token. This is the field qualifier and we do
						NOT want to include it in the final value.
					--->
					<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst( "^.{1}", "" ) />

					<!---
						Remove all double qualifiers so that we can test to see if the field has a closing qualifier.
					--->
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll( "\#ARGUMENTS.Qualifier#{2}", "{QUALIFIER}" ) />

					<!---
						Check to see if this field is a self-closer. If the first character is a qualifier (already established) and the
						last character is also a qualifier (what we are about to test for), then this token is a fully qualified value.
					--->
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<!---
							This token is fully qualified. Remove the end field qualifier and append it to the row data.
						--->
						<cfset ArrayAppend( LOCAL.Rows[ LOCAL.RowIndex ], LOCAL.Token.ReplaceFirst( ".{1}$", "" ) ) />
					<cfelse>
						<!---
							This token is not fully qualified (but the first character was a qualifier). We are buildling a value
							up across differen tokens. Set the flag for building the value.
						--->
						<cfset LOCAL.IsInValue = true />

						<!--- Add this token to the row. --->
						<cfset ArrayAppend( LOCAL.Rows[ LOCAL.RowIndex ], LOCAL.Token ) />
					</cfif>
				<cfelse>
					<!---
						We are not dealing with a qualified field (even though we are using field qualifiers). Just add this token value
						as the next value in the row.
					--->
					<cfset ArrayAppend( LOCAL.Rows[ LOCAL.RowIndex ], LOCAL.Token ) />
				</cfif>
			</cfif>

			<!---
				As a sort of catch-all, let's remove that {QUALIFIER} constant that we may have thrown into a field value. Do NOT use the FieldIndex
				value as this might be a corrupt value at this point in the token iteration.
			--->
			<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace( LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ], "{QUALIFIER}", ARGUMENTS.Qualifier, "ALL" ) />
		<cfelse>
			<!---
				Since we don't have a qualifier, just use the current raw token as the actual value. We are
				NOT going to have to worry about building values across tokens.
			--->
			<cfset ArrayAppend( LOCAL.Rows[ LOCAL.RowIndex ], LOCAL.Token ) />
		</cfif>

		<!---
			Check to see if we have a next delimiter and if we do, is it going to start a new row? Be cautious that
			we are NOT in the middle of building a value. If we are building a value then the line delimiter is an
			embedded value and should not percipitate a new row.
		--->
		<cfif ( (NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND (LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter) )>
			<!---
				The next token is indicating that we are about start a new row. Add a new array to the parent and increment the row counter.
			--->
			<cfset ArrayAppend( LOCAL.Rows, ArrayNew( 1 ) ) />

			<!--- Increment row index to point to next row. --->
			<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
		</cfif>
	</cfloop>

	<!---
		ASSERT: At this point, we have parsed the CSV into an array of arrays (LOCAL.Rows). Now, we can take that array of arrays and convert it into a query.
	--->

	<!---
		To create a query that fits this array of arrays, we need to figure out the max length for each row as well as the number of records.
		The number of records is easy - it's the length of the array. The max field count per row is not that easy. We will have to iterate over each row to find the max.
		However, this works to our advantage as we can use that array iteration as an opportunity to build up a single array of empty string that we will use to pre-populate
		the query.
	--->

	<!--- Set the initial max field count. --->
	<cfset LOCAL.MaxFieldCount = 0 />

	<!---
		Set up the array of empty values. As we iterate over the rows, we are going to add an empty value to this for each record (not field) that we find.
	--->
	<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />

	<!--- Loop over the records array. --->
	<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
		<!--- Get the max rows encountered so far. --->
		<cfset LOCAL.MaxFieldCount = Max( LOCAL.MaxFieldCount, ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ) />

		<!--- Add an empty value to the empty array. --->
		<cfset ArrayAppend( LOCAL.EmptyArray, "" ) />
	</cfloop>

	<!---
		ASSERT: At this point, LOCAL.MaxFieldCount should hold the number of fields in the widest row. Additionally,
		the LOCAL.EmptyArray should have the same number of indexes as the row array - each index containing an empty string.
	--->

	<!---
		Now, let's pre-populate the query with empty strings. We are going to create the query as all VARCHAR data
		fields, starting off with blank. Then we will override these values shortly.
	--->
	<cfset LOCAL.Query = QueryNew( "" ) />

	<!---
		Loop over the max number of fields and create a column for each records.
	--->
	<cfloop index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
		<!---
			Add a new query column. By using QueryAddColumn() rather than QueryAddRow() we are able to leverage
			ColdFusion's ability to add row values in bulk based on an array of values. Since we are going to
			pre-populate the query with empty values, we can just send in the EmptyArray we built previously.
		--->
		<cfset QueryAddColumn( LOCAL.Query, "COLUMN_#LOCAL.FieldIndex#", "CF_SQL_VARCHAR", LOCAL.EmptyArray ) />
	</cfloop>

	<!---
		ASSERT: At this point, our return query LOCAL.Query contains enough columns and rows to handle all the
		data that we have stored in our array of arrays.
	--->

	<!---
		Loop over the array to populate the query with actual data. We are going to have to loop over each row and then each field.
	--->
	<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
		<!--- Loop over the fields in this record. --->
		<cfloop index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
			<!---
				Update the query cell. Remember to cast string to make sure that the underlying Java data works properly.
			--->
			<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast( "string", LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] ) />
		</cfloop>
	</cfloop>

	<!---
		Our query has been successfully populated. Now, return it.
	--->
		<cfreturn LOCAL.Query />
	</cffunction>

	<cffunction name="importzipcodes" returntype="any" output="true">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfset Session.FormData = #StructCopy(FORM)#>
				<cfset Session.FormErrors = #ArrayNew()#>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset CurrentDir = #ExpandPath("*.csv")#>
			<cfset USZipCodeFilesDir = #Left(Variables.CurrentDir, Find("*.csv", Variables.CurrentDir) - 1)# & "plugin/datafiles/USZipCodes/">
			<cfdirectory action="list" directory="#Variables.USZipCodeFilesDir#" filter="*.csv" name="USZipCodesDirData">
			<cfset FORM.ImportUSZipCodePrefix = "-" & #FORM.ImportUSZipCodePrefix#>
			<cfloop query="USZipCodesDirData">
				<cfif Find(FORM.ImportUSZipCodePrefix, USZipCodesDirData.Name)>
					<cffile action="read" file="#Variables.USZipCodeFilesDir##USZipCodesDirData.Name#" variable="ReadUSZipCodesData">
					<cfset CSVQuery = #CSVToQuery(Variables.ReadUSZipCodesData, ",", '"')#>
					<cfloop query="CSVQuery">
						<cfif CSVQuery.currentRow GTE 2 and Len(CSVQuery.Column_2)>
							<cfquery name="insertZipCode" result="insertZipCodes" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								insert into pZipCodes(Site_ID, ZipCode, City, State, Latitude, Longitude, StateFIPS)
								Values(
									<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#CSVQuery.Column_1#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#CSVQuery.Column_3#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#CSVQuery.Column_2#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#CSVQuery.Column_7#" cfsqltype="CF_SQL_DECIMAL">,
									<cfqueryparam value="#CSVQuery.Column_8#" cfsqltype="CF_SQL_DECIMAL">,
									<cfqueryparam value="#CSVQuery.Column_5#" cfsqltype="CF_SQL_VARCHAR">
								)
							</cfquery>
						</cfif>
					</cfloop>
					<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=True&Action=ImportZipCodes" addtoken="false">
				</cfif>
			</cfloop>
			<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=False&Action=ImportZipCodes" addtoken="false">
		</cfif>
	</cffunction>

	<cffunction name="importncespublicschoolbuildingdata" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNow()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfset Session.FormData = #StructCopy(FORM)#>
				<cfset Session.FormErrors = #ArrayNew()#>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset CurrentDir = #ExpandPath("*.csv")#>
			<cfset SchoolBuildingFilesDir = #Left(Variables.CurrentDir, Find("*.csv", Variables.CurrentDir) - 1)# & "plugin/datafiles/SchoolBuildings/">
			<cfdirectory action="list" directory="#Variables.SchoolBuildingFilesDir#" filter="*.csv" name="SchoolBuildingData">
			<cfset FORM.ImportStateSchoolBuildings = "_" & #FORM.ImportStateSchoolBuildings#>
			<cfloop query="SchoolBuildingData">
				<cfif Find(FORM.ImportStateSchoolBuildings, SchoolBuildingData.Name)>
					<cffile action="read" file="#Variables.SchoolBuildingFilesDir##SchoolBuildingData.Name#" variable="ReadStateSchoolBuildings">
					<cfset CSVQuery = #CSVToQuery(Variables.ReadStateSchoolBuildings, ",", '"')#>

					<cfloop query="CSVQuery">
						<cfif CSVQuery.currentRow GTE 2 and Len(CSVQuery.Column_2)>
							<cfquery name="insertSchoolBuilding" result="insertSchoolBuilding" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								insert into pSchoolBuildings(Site_ID, NCES_ID, SchoolDistrict_NCES_ID, SchoolName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, dateCreated, lastUpdated, lastUpdateBy, GeoCode_Latitude, GeoCode_Longitude, BuildingLowestGradeLevel,  BuildingHighestGradeLevel, State_DistrictID, State_SchoolID, FIPS_StateCode)
								Values(
								<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_4#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_6#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_1#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_10#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_11#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_12#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_13#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_14#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_20#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_timestamp">,
								<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_timestamp">,
								<cfqueryparam value="Admin User" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_22#" cfsqltype="CF_SQL_DECIMAL">,
								<cfqueryparam value="#CSVQuery.Column_23#" cfsqltype="CF_SQL_DECIMAL">,
								<cfqueryparam value="#CSVQuery.Column_27#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_28#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_24#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_25#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_9#" cfsqltype="CF_SQL_VARCHAR">
								)
							</cfquery>
						</cfif>
					</cfloop>
					<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=True&Action=ImportSchoolBuildings" addtoken="false">
				</cfif>
			</cfloop>
			<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=False&Action=ImportSchoolBuildings" addtoken="false">
		</cfif>
	</cffunction>

	<cffunction name="importncespublicschooldistrictdata" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNow()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfset Session.FormData = #StructCopy(FORM)#>
				<cfset Session.FormErrors = #ArrayNew()#>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset CurrentDir = #ExpandPath("*.csv")#>
			<cfset SchoolDistrictsFilesDir = #Left(Variables.CurrentDir, Find("*.csv", Variables.CurrentDir) - 1)# & "plugin/datafiles/SchoolDistricts/">
			<cfdirectory action="list" directory="#Variables.SchoolDistrictsFilesDir#" filter="*.csv" name="SchoolDistrictsData">
			<cfset FORM.ImportStateSchoolBuildings = "_" & #FORM.ImportStateSchoolBuildings#>
			<cfloop query="SchoolDistrictsData">
				<cfif Find(FORM.ImportStateSchoolBuildings, SchoolDistrictsData.Name)>
					<cffile action="read" file="#Variables.SchoolDistrictsFilesDir##SchoolDistrictsData.Name#" variable="ReadStateSchoolDistricts">
					<cfset CSVQuery = #CSVToQuery(Variables.ReadStateSchoolDistricts, ",", '"')#>
					<cfloop query="CSVQuery">
						<cfif CSVQuery.currentRow GTE 2 and Len(CSVQuery.Column_1)>
							<cfquery name="insertSchoolDistricts" result="insertSchoolDistricts" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								insert into pSchoolDistricts(Site_ID, NCES_ID, DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, dateCreated, lastUpdated, lastUpdateBy, GeoCode_Latitude, GeoCode_Longitude, LowestGradeLevel,  HighestGradeLevel, Total_NumberStudents, Total_OperationalSchools, StateAgency_IDNumber, CountyName, CountyNumber, FIPS_StateCode, MailingAddress, MailingCity, MailingState, MailingZipCode, MailingZip4)
								Values(
								<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_3#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_1#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_8#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_9#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_10#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_11#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_12#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_18#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_timestamp">,
								<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_timestamp">,
								<cfqueryparam value="Admin User" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_20#" cfsqltype="CF_SQL_DECIMAL">,
								<cfqueryparam value="#CSVQuery.Column_21#" cfsqltype="CF_SQL_DECIMAL">,
								<cfqueryparam value="#CSVQuery.Column_23#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_24#" cfsqltype="CF_SQL_VARCHAR">,
								<cfif isNumeric(CSVQuery.Column_26)>
									<cfqueryparam value="#CSVQuery.Column_26#" cfsqltype="CF_SQL_Number">,
								<cfelse>
									<cfqueryparam value="0" cfsqltype="CF_SQL_Number">,
								</cfif>
								<cfqueryparam value="#CSVQuery.Column_7#" cfsqltype="CF_SQL_Number">,
								<cfqueryparam value="#CSVQuery.Column_22#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_4#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_5#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_6#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_13#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_14#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_15#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_16#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#CSVQuery.Column_17#" cfsqltype="CF_SQL_VARCHAR">
								)
							</cfquery>
						</cfif>
					</cfloop>
					<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=True&Action=ImportSchoolDistricts" addtoken="false">
				</cfif>
			</cfloop>
			<cflocation url="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/index.cfm?ActionSuccessfull=False&Action=ImportSchoolDistricts" addtoken="false">
		</cfif>
	</cffunction>

	<cffunction name="generatemapdatafiles" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNow()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfset Session.FormData = #StructCopy(FORM)#>
				<cfset Session.FormErrors = #ArrayNew()#>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset CurrentDir = #ExpandPath("*.csv")#>
			<cfset USAMapXMLFileDir = #Left(Variables.CurrentDir, Find("*.csv", Variables.CurrentDir) - 1)# & "includes/assets/flash/">
			<cfset USAMapXMLFilename = #Variables.USAMapXMLFileDir# & "usaMapSettings.xml">

			<cfswitch expression="#FORM.CreateMapXMLDataFiles#">
				<cfcase value="1">
					<cfquery name="getAllSchoolDistricts" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select NCES_ID, DistrictName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, HighestGradeLevel, LowestGradeLevel, Total_NumberStudents, Total_OperationalSchools
						From pSchoolDistricts
					</cfquery>
					<cfquery name="GetAlabamaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'AL' </cfquery>
					<cfquery name="GetAlaskaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'AK' </cfquery>
					<cfquery name="GetArizonaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'AZ' </cfquery>
					<cfquery name="GetArkansasDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'AR' </cfquery>
					<cfquery name="GetCaliforniaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'CA' </cfquery>
					<cfquery name="GetColoradoDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'CO' </cfquery>
					<cfquery name="GetConnecticutDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'CT' </cfquery>
					<cfquery name="GetDelawareDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'DE' </cfquery>
					<cfquery name="GetFloridaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'FL' </cfquery>
					<cfquery name="GetGeorgiaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'GA' </cfquery>
					<cfquery name="GetHawaiiDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'HI' </cfquery>
					<cfquery name="GetIdahoDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'ID' </cfquery>
					<cfquery name="GetIllinoisDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'IL' </cfquery>
					<cfquery name="GetIndianaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'IN' </cfquery>
					<cfquery name="GetIowaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'IA' </cfquery>
					<cfquery name="GetKansasDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'KS' </cfquery>
					<cfquery name="GetKansasDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'KS' </cfquery>
					<cfquery name="GetKentuckyDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'KY' </cfquery>
					<cfquery name="GetLouisianaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'LA' </cfquery>
					<cfquery name="GetMaineDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'ME' </cfquery>
					<cfquery name="GetMarylandDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MD' </cfquery>
					<cfquery name="GetMassachusettsDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MA' </cfquery>
					<cfquery name="GetMichiganDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MI' </cfquery>
					<cfquery name="GetMinnesotaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MN' </cfquery>
					<cfquery name="GetMississippiDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MS' </cfquery>
					<cfquery name="GetMissouriDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MO' </cfquery>
					<cfquery name="GetMontanaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'MT' </cfquery>
					<cfquery name="GetNebraskaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NE' </cfquery>
					<cfquery name="GetNevadaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NV' </cfquery>
					<cfquery name="GetNewHampshireDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NH' </cfquery>
					<cfquery name="GetNewJerseyDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NJ' </cfquery>
					<cfquery name="GetNewMexicoDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NM' </cfquery>
					<cfquery name="GetNewYorkDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NY' </cfquery>
					<cfquery name="GetNorthCarolinaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'NC' </cfquery>
					<cfquery name="GetNorthDakotaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'ND' </cfquery>
					<cfquery name="GetOhioDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'OH' </cfquery>
					<cfquery name="GetOklahomaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'OK' </cfquery>
					<cfquery name="GetOregonDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'OR' </cfquery>
					<cfquery name="GetPennsylvaniaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'PA' </cfquery>
					<cfquery name="GetRhodeIslandDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'RI' </cfquery>
					<cfquery name="GetSouthCarolinaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'SC' </cfquery>
					<cfquery name="GetSouthDakotaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'SD' </cfquery>
					<cfquery name="GetTennesseeDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'TN' </cfquery>
					<cfquery name="GetTexasDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'TX' </cfquery>
					<cfquery name="GetUtahDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'UT' </cfquery>
					<cfquery name="GetVermontDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'VT' </cfquery>
					<cfquery name="GetVirginiaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'VA' </cfquery>
					<cfquery name="GetWashingtonDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'WA' </cfquery>
					<cfquery name="GetWestVirginiaDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'WV' </cfquery>
					<cfquery name="GetWisconsinDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'WI' </cfquery>
					<cfquery name="GetWyomingDistricts" dbtype="query">Select * From getAllSchoolDistricts Where PhysicalState = 'WY' </cfquery>

					<cfquery name="getAllSchoolBuildings" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select NCES_ID, SchoolDistrict_NCES_ID, SchoolName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, BuildingLowestGradeLevel, BuildingHighestGradeLevel
						From pSchoolBuildings
					</cfquery>

					<cfquery name="GetAlabamaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'AL' </cfquery>
					<cfquery name="GetAlaskaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'AK' </cfquery>
					<cfquery name="GetArizonaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'AZ' </cfquery>
					<cfquery name="GetArkansasBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'AR' </cfquery>
					<cfquery name="GetCaliforniaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'CA' </cfquery>
					<cfquery name="GetColoradoBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'CO' </cfquery>
					<cfquery name="GetConnecticutBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'CT' </cfquery>
					<cfquery name="GetDelawareBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'DE' </cfquery>
					<cfquery name="GetFloridaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'FL' </cfquery>
					<cfquery name="GetGeorgiaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'GA' </cfquery>
					<cfquery name="GetHawaiiBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'HI' </cfquery>
					<cfquery name="GetIdahoBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'ID' </cfquery>
					<cfquery name="GetIllinoisBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'IL' </cfquery>
					<cfquery name="GetIndianaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'IN' </cfquery>
					<cfquery name="GetIowaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'IA' </cfquery>
					<cfquery name="GetKansasBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'KS' </cfquery>
					<cfquery name="GetKansasBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'KS' </cfquery>
					<cfquery name="GetKentuckyBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'KY' </cfquery>
					<cfquery name="GetLouisianaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'LA' </cfquery>
					<cfquery name="GetMaineBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'ME' </cfquery>
					<cfquery name="GetMarylandBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MD' </cfquery>
					<cfquery name="GetMassachusettsBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MA' </cfquery>
					<cfquery name="GetMichiganBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MI' </cfquery>
					<cfquery name="GetMinnesotaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MN' </cfquery>
					<cfquery name="GetMississippiBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MS' </cfquery>
					<cfquery name="GetMissouriBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MO' </cfquery>
					<cfquery name="GetMontanaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'MT' </cfquery>
					<cfquery name="GetNebraskaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NE' </cfquery>
					<cfquery name="GetNevadaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NV' </cfquery>
					<cfquery name="GetNewHampshireBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NH' </cfquery>
					<cfquery name="GetNewJerseyBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NJ' </cfquery>
					<cfquery name="GetNewMexicoBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NM' </cfquery>
					<cfquery name="GetNewYorkBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NY' </cfquery>
					<cfquery name="GetNorthCarolinaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'NC' </cfquery>
					<cfquery name="GetNorthDakotaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'ND' </cfquery>
					<cfquery name="GetOhioBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'OH' </cfquery>
					<cfquery name="GetOklahomaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'OK' </cfquery>
					<cfquery name="GetOregonBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'OR' </cfquery>
					<cfquery name="GetPennsylvaniaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'PA' </cfquery>
					<cfquery name="GetRhodeIslandBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'RI' </cfquery>
					<cfquery name="GetSouthCarolinaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'SC' </cfquery>
					<cfquery name="GetSouthDakotaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'SD' </cfquery>
					<cfquery name="GetTennesseeBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'TN' </cfquery>
					<cfquery name="GetTexasBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'TX' </cfquery>
					<cfquery name="GetUtahBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'UT' </cfquery>
					<cfquery name="GetVermontBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'VT' </cfquery>
					<cfquery name="GetVirginiaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'VA' </cfquery>
					<cfquery name="GetWashingtonBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'WA' </cfquery>
					<cfquery name="GetWestVirginiaBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'WV' </cfquery>
					<cfquery name="GetWisconsinBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'WI' </cfquery>
					<cfquery name="GetWyomingBuildings" dbtype="query">Select * From getAllSchoolBuildings Where PhysicalState = 'WY' </cfquery>

					<cfset First17PercentInitialColor = "663300">
					<cfset First17PercentOverColor = "ffcc99">
					<cfset First17PercentSelectedColor = "fff2e5">

					<cfset Second17PercentInitialColor = "993333">
					<cfset Second17PercentOverColor = "e3b3b3">
					<cfset Second17PercentSelectedColor = "f9ecec">

					<cfset Third17PercentInitialColor = "660066">
					<cfset Third17PercentOverColor = "ff99ff">
					<cfset Third17PercentSelectedColor = "ffe5ff">

					<cfset Fourth17PercentInitialColor = "000066">
					<cfset Fourth17PercentOverColor = "9999ff">
					<cfset Fourth17PercentSelectedColor = "e5e5ff">

					<cfset Fifth17PercentInitialColor = "003366">
					<cfset Fifth17PercentOverColor = "99ccff">
					<cfset Fifth17PercentSelectedColor = "e5f2ff">

					<cfset Sixth17PercentInitialColor = "003300">
					<cfset Sixth17PercentOverColor = "99ff99">
					<cfset Sixth17PercentSelectedColor = "e5ffe5">

					<cfoutput><cfsavecontent variable="xmlData">
						<?xml version="1.0" encoding="UTF-8"?>
						<datas>
							<mapSettings stageOutlineColor = 'FFFFFF' urlTarget = '_self' offColor = 'ABAB9B' offStateTextColor = 'FFFFFF' />
							<cfif GetAlabamaDistricts.RecordCount or GetAlabamaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=ALABAMA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ALABAMA</b><br>Number School Districts: <cfoutput>#GetAlabamaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetAlabamaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
								<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=ALABAMA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ALABAMA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetAlaskaDistricts.RecordCount or GetAlaskaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=ALASKA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ALASKA</b><br>Number School Districts: <cfoutput>#GetAlaskaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetAlaskaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=ALASKA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ALASKA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetArizonaDistricts.RecordCount or GetArizonaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=ARIZONA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ARIZONA</b><br>Number School Districts: <cfoutput>#GetArizonaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetArizonaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=ARIZONA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ARIZONA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetArkansasDistricts.RecordCount or GetArkansasBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=ARKANSAS' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ARKANSAS</b><br>Number School Districts: <cfoutput>#GetArkansasDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetArkansasBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=ARKANSAS' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ARKANSAS</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetCaliforniaDistricts.RecordCount or GetCaliforniaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=CALIFORNIA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>CALIFORNIA</b><br>Number School Districts: <cfoutput>#GetCaliforniaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetCaliforniaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=CALIFORNIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>CALIFORNIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetColoradoDistricts.RecordCount or GetColoradoBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=COLORADO' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>COLORADO</b><br>Number School Districts: <cfoutput>#GetColoradoDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetColoradoBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=COLORADO' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>COLORADO</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetConnecticutDistricts.RecordCount or GetConnecticutBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=CONNECTICUT' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>CONNECTICUT</b><br>Number School Districts: <cfoutput>#GetConnecticutDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetConnecticutBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=CONNECTICUT' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>CONNECTICUT</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetDelawareDistricts.RecordCount or GetDelawareBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=DELAWARE' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>DELAWARE</b><br>Number School Districts: <cfoutput>#GetDelawareDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetDelawareBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=DELAWARE' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>DELAWARE</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetIndianaDistricts.RecordCount or GetIndianaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=DISTRICTOFCOLUMBIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>DISTRICT OF COLUMBIA</b> ]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=DISTRICTOFCOLUMBIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>DISTRICT OF COLUMBIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetFloridaDistricts.RecordCount or GetFloridaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=FLORIDA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>FLORIDA</b><br>Number School Districts: <cfoutput>#GetFloridaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetFloridaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=FLORIDA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>FLORIDA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetGeorgiaDistricts.RecordCount or GetGeorgiaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=GEORGIA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>GEORGIA</b><br>Number School Districts: <cfoutput>#GetGeorgiaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetGeorgiaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=GEORGIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>GEORGIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetHawaiiDistricts.RecordCount or GetHawaiiBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=HAWAII' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>HAWAII</b><br>Number School Districts: <cfoutput>#GetHawaiiDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetHawaiiBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=HAWAII' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>HAWAII</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetIdahoDistricts.RecordCount or GetIdahoBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=IDAHO' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>IDAHO</b><br>Number School Districts: <cfoutput>#GetIdahoDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetIdahoBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=IDAHO' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>IDAHO</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetIllinoisDistricts.RecordCount or GetIllinoisBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=ILLINOIS' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ILLINOIS</b><br>Number School Districts: <cfoutput>#GetIllinoisDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetIllinoisBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=ILLINOIS' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>ILLINOIS</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetIndianaDistricts.RecordCount or GetIndianaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=INDIANA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>INDIANA</b><br>Number School Districts: <cfoutput>#GetIndianaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetIndianaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=INDIANA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>INDIANA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetIowaDistricts.RecordCount or GetIowaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=IOWA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>IOWA</b><br>Number School Districts: <cfoutput>#GetIowaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetIowaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=IOWA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>IOWA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetKansasDistricts.RecordCount or GetKansasBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=KANSAS' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>KANSAS</b><br>Number School Districts: <cfoutput>#GetKansasDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetKansasBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=KANSAS' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>KANSAS</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetKentuckyDistricts.RecordCount or GetKentuckyBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=KENTUCKY' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>KENTUCKY</b><br>Number School Districts: <cfoutput>#GetKentuckyDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetKentuckyBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=KENTUCKY' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>KENTUCKY</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetLouisianaDistricts.RecordCount or GetLouisianaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=LOUISIANA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>LOUISIANA</b><br>Number School Districts: <cfoutput>#GetLouisianaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetLouisianaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=LOUISIANA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>LOUISIANA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMaineDistricts.RecordCount or GetMaineBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MAINE' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MAINE</b><br>Number School Districts: <cfoutput>#GetMaineDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMaineBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MAINE' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MAINE</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMarylandDistricts.RecordCount or GetMarylandBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MARYLAND' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MARYLAND</b><br>Number School Districts: <cfoutput>#GetMarylandDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMarylandBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MARYLAND' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MARYLAND</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMassachusettsDistricts.RecordCount or GetMassachusettsBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MASSACHUSETTS' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MASSACHUSETTS</b><br>Number School Districts: <cfoutput>#GetMassachusettsDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMassachusettsBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MASSACHUSETTS' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MASSACHUSETTS</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMichiganDistricts.RecordCount or GetMichiganBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MICHIGAN' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MICHIGAN</b><br>Number School Districts: <cfoutput>#GetMichiganDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMichiganBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MICHIGAN' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MICHIGAN</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMinnesotaDistricts.RecordCount or GetMinnesotaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MINNESOTA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MINNESOTA</b><br>Number School Districts: <cfoutput>#GetMinnesotaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMinnesotaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MINNESOTA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MINNESOTA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMississippiDistricts.RecordCount or GetMississippiBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MISSISSIPPI' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MISSISSIPPI</b><br>Number School Districts: <cfoutput>#GetMississippiDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMississippiBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MISSISSIPPI' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MISSISSIPPI</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMissouriDistricts.RecordCount or GetMissouriBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MISSOURI' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MISSOURI</b><br>Number School Districts: <cfoutput>#GetMissouriDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMissouriBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MISSOURI' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MISSOURI</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetMontanaDistricts.RecordCount or GetMontanaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=MONTANA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MONTANA</b><br>Number School Districts: <cfoutput>#GetMontanaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetMontanaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=MONTANA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>MONTANA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNebraskaDistricts.RecordCount or GetNebraskaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEBRASKA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEBRASKA</b><br>Number School Districts: <cfoutput>#GetNebraskaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNebraskaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEBRASKA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEBRASKA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNevadaDistricts.RecordCount or GetNevadaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEVADA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEVADA</b><br>Number School Districts: <cfoutput>#GetNevadaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNevadaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEVADA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEVADA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNewHampshireDistricts.RecordCount or GetNewHampshireBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEWHAMPSHIRE' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW HAMPSHIRE</b><br>Number School Districts: <cfoutput>#GetNewHampshireDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNewHampshireBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEWHAMPSHIRE' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW HAMPSHIRE</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNewJerseyDistricts.RecordCount or GetNewJerseyBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEWJERSEY' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW JERSEY</b><br>Number School Districts: <cfoutput>#GetNewJerseyDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNewJerseyBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEWJERSEY' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW JERSEY</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNewMexicoDistricts.RecordCount or GetNewMexicoBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEWMEXICO' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW MEXICO</b><br>Number School Districts: <cfoutput>#GetNewMexicoDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNewMexicoBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEWMEXICO' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW MEXICO</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNewYorkDistricts.RecordCount or GetNewYorkBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NEWYORK' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW YORK</b><br>Number School Districts: <cfoutput>#GetNewYorkDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNewYorkBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NEWYORK' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NEW YORK</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNorthCarolinaDistricts.RecordCount or GetNorthCarolinaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NORTHCAROLINA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NORTH CAROLINA</b><br>Number School Districts: <cfoutput>#GetNorthCarolinaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNorthCarolinaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NORTHCAROLINA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NORTH CAROLINA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetNorthDakotaDistricts.RecordCount or GetNorthDakotaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=NORTHDAKOTA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NORTH DAKOTA</b><br>Number School Districts: <cfoutput>#GetNorthDakotaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetNorthDakotaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=NORTHDAKOTA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>NORTH DAKOTA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetOhioDistricts.RecordCount or GetOhioBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=OHIO' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OHIO</b><br>Number School Districts: <cfoutput>#GetOhioDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetOhioBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=OHIO' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OHIO</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetOklahomaDistricts.RecordCount or GetOklahomaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=OKLAHOMA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OKLAHOMA</b><br>Number School Districts: <cfoutput>#GetOklahomaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetOklahomaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=OKLAHOMA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OKLAHOMA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetOregonDistricts.RecordCount or GetOregonBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=OREGON' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OREGON</b><br>Number School Districts: <cfoutput>#GetOregonDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetOregonBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=OREGON' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>OREGON</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetPennsylvaniaDistricts.RecordCount or GetPennsylvaniaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=PENNSYLVANIA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>PENNSYLVANIA</b><br>Number School Districts: <cfoutput>#GetPennsylvaniaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetPennsylvaniaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=PENNSYLVANIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>PENNSYLVANIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetRhodeIslandDistricts.RecordCount or GetRhodeIslandBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=RHODEISLAND' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>RHODE ISLAND</b><br>Number School Districts: <cfoutput>#GetRhodeIslandDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetRhodeIslandBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=RHODEISLAND' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>RHODE ISLAND</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetSouthCarolinaDistricts.RecordCount or GetSouthCarolinaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=SOUTHCAROLINA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>SOUTH CAROLINA</b><br>Number School Districts: <cfoutput>#GetSouthCarolinaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetSouthCarolinaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=SOUTHCAROLINA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>SOUTH CAROLINA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetSouthDakotaDistricts.RecordCount or GetSouthDakotaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=SOUTHDAKOTA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>SOUTH DAKOTA</b><br>Number School Districts: <cfoutput>#GetSouthDakotaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetSouthDakotaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=SOUTHDAKOTA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>SOUTH DAKOTA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetTennesseeDistricts.RecordCount or GetTennesseeBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=TENNESSEE' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>TENNESSEE</b><br>Number School Districts: <cfoutput>#GetTennesseeDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetTennesseeBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=TENNESSEE' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>TENNESSEE</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetTexasDistricts.RecordCount or GetTexasBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=TEXAS' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>TEXAS</b><br>Number School Districts: <cfoutput>#GetTexasDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetTexasBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=TEXAS' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>TEXAS</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetUtahDistricts.RecordCount or GetUtahBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=UTAH' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>UTAH</b><br>Number School Districts: <cfoutput>#GetUtahDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetUtahBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=UTAH' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>UTAH</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetVermontDistricts.RecordCount or GetVermontBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=VERMONT' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>VERMONT</b><br>Number School Districts: <cfoutput>#GetVermontDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetVermontBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=VERMONT' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>VERMONT</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetVirginiaDistricts.RecordCount or GetVirginiaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=VIRGINIA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>VIRGINIA</b><br>Number School Districts: <cfoutput>#GetVirginiaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetVirginiaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=VIRGINIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>VIRGINIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetWashingtonDistricts.RecordCount or GetWashingtonBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=WASHINGTON' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WASHINGTON</b><br>Number School Districts: <cfoutput>#GetWashingtonDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetWashingtonBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=WASHINGTON' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WASHINGTON</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetWestVirginiaDistricts.RecordCount or GetWestVirginiaBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=WESTVIRGINIA' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WEST VIRGINIA</b><br>Number School Districts: <cfoutput>#GetWestVirginiaDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetWestVirginiaBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=WESTVIRGINIA' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WEST VIRGINIA</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetWisconsinDistricts.RecordCount or GetWisconsinBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=WISCONSIN' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WISCONSIN</b><br>Number School Districts: <cfoutput>#GetWisconsinDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetWisconsinBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=WISCONSIN' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WISCONSIN</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
							<cfif GetWyomingDistricts.RecordCount or GetWyomingBuildings.RecordCount>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:viewinformation.default&State=WYOMING' stateMode = 'ON' initialProvincesColor= '#Variables.First17PercentInitialColor#' provinceOverColor = '#Variables.First17PercentOverColor#' provinceSelectedColor = '#Variables.First17PercentSelectedColor#' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WYOMING</b><br>Number School Districts: <cfoutput>#GetWyomingDistricts.RecordCount#</cfoutput><br>Number School Buildings: <cfoutput>#GetWyomingBuildings.RecordCount#</cfoutput>]]>
							</stateData>
							<cfelse>
							<stateData url = '/plugins/1To1TechLocator/index.cfm?1To1TechLocatoraction=public:contactus.default&State=WYOMING' stateMode = 'ON' initialProvincesColor= '000000' provinceOverColor = 'CCCCCC' provinceSelectedColor = 'F2F2F2' initialProvinceTextColor = 'FFFFFF' provinceTextOverColor = '000000' provinceTextSelectedColor = '1C3753' tooltipWidth = '200'>
								<![CDATA[ <b>WYOMING</b><br>If you are current doing a 1:1 Inititive in a school district or school building within this state, please click to complete a form that will be submitted to us so we can populate the School Districts and Buildings for this state.]]>
							</stateData>
							</cfif>
						</datas>
					</cfsavecontent></cfoutput>
					<cffile action="write" output="#Variables.xmlData#" file="#Variables.USAMapXMLFilename#" addNewLine="No">
				</cfcase>
				<cfcase value="0">

				</cfcase>
			</cfswitch>
		</cfif>

	</cffunction>
</cfcomponent>
