/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent persistent="false" accessors="true" output="false" extends="mura.plugin.plugincfc">
	<cfparam name="config" type="any" default="">

	<cffunction name="init" output="false" returntype="any">
		<cfargument name="config" required="true" default="">
	</cffunction>

	<cffunction name="install" output="true" returntype="any">
		<cfset application.appInitialized = false>

		<cfset PluginInfo = #Variables.getPlugin(Session.ModuleID)#>
		<cfset GeoCodeAddrCFC = createObject("component","plugins/#PluginInfo.getName()#/library/components/EventServices")>

		<cfscript>
			var dbCheckTableSchoolDistricts = new query();
			dbCheckTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableSchoolDistricts.setSQL("Show Tables LIKE 'pSchoolDistricts'");
			var dbCheckTableSchoolDistrictsResults = dbCheckTableSchoolDistricts.execute();

			if (dbCheckTableSchoolDistrictsResults.getResult().recordcount eq 0) {
				// Since the Database Table does not exists, Lets Create it
				var dbCreateTableSchoolDistricts = new query();
				dbCreateTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTableSchoolDistricts.setSQL("CREATE TABLE `pSchoolDistricts` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(8) NOT NULL, `DistrictName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `LowestGradeLevel` tinytext NOT NULL, `HighestGradeLevel` tinytext NOT NULL, `Total_NumberStudents` int(11) DEFAULT NULL, `Total_OperationalSchools` int(11) DEFAULT NULL, `StateAgency_IDNumber` tinytext, `CountyName` tinytext, `CountyNumber` tinytext, PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`), UNIQUE KEY `NCES_ID` (`NCES_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
				var dbCreateTableSchoolDistrictsResults = dbCreateTableSchoolDistricts.execute();
			} else {
				// Database Table Exists, We must Drop it to create it again
				var dbDropTableSchoolDistricts = new query();
				dbDropTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableSchoolDistricts.setSQL("DROP TABLE pSchoolDistricts");
				var dbDropTableSchoolDistrictsResults = dbDropTableSchoolDistricts.execute();

				if (len(dbDropTableSchoolDistrictsResults.getResult()) eq 0) {
					var dbCreateTableSchoolDistricts = new query();
					dbCreateTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
					dbCreateTableSchoolDistricts.setSQL("CREATE TABLE `pSchoolDistricts` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(8) NOT NULL, `DistrictName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `LowestGradeLevel` tinytext NOT NULL, `HighestGradeLevel` tinytext NOT NULL, `Total_NumberStudents` int(11) DEFAULT NULL, `Total_OperationalSchools` int(11) DEFAULT NULL, `StateAgency_IDNumber` tinytext, `CountyName` tinytext, `CountyNumber` tinytext, PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`), UNIQUE KEY `NCES_ID` (`NCES_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
					var dbCreateTableSchoolDistrictsResults = dbCreateTableSchoolDistricts.execute();
				} else {
				 writedump(dbCreateTableSchoolDistrictsResults.getResult());
				 abort;
				}
			}

			var dbCheckTableSchoolBuildings = new query();
			dbCheckTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableSchoolBuildings.setSQL("Show Tables LIKE 'pSchoolBuildings'");
			var dbCheckTableSchoolBuildingsResults = dbCheckTableSchoolBuildings.execute();

			if (dbCheckTableSchoolBuildingsResults.getResult().recordcount eq 0) {
				// Since the Database Table does not exists, Lets Create it
				var dbCreateTableSchoolBuildings = new query();
				dbCreateTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTableSchoolBuildings.setSQL("CREATE TABLE `pSchoolBuildings` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `SchoolDistrict_NCES_ID` char(10) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(12) NOT NULL, `SchoolName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `SchoolWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `State_SchoolID` tinytext, `State_DistrictID` tinytext, `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `BuildingLowestGradeLevel` tinytext NOT NULL, `BuildingHighestGradeLevel` tinytext NOT NULL, PRIMARY KEY (`TContent_ID`,`SchoolDistrict_NCES_ID`,`NCES_ID`), UNIQUE KEY `NCES_ID` (`NCES_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
				var dbCreateTableSchoolBuildingsResults = dbCreateTableSchoolBuildings.execute();
			} else {
				// Database Table Exists, We must Drop it to create it again
				var dbDropTableSchoolBuildings = new query();
				dbDropTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableSchoolBuildings.setSQL("DROP TABLE pSchoolBuildings");
				var dbDropTableSchoolBuildingsResults = dbDropTableSchoolBuildings.execute();

				if (len(dbDropTableSchoolBuildingsResults.getResult()) eq 0) {
					var dbCreateTableSchoolBuildings = new query();
					dbCreateTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
					dbCreateTableSchoolBuildings.setSQL("CREATE TABLE `pSchoolBuildings` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `SchoolDistrict_NCES_ID` char(10) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(12) NOT NULL, `SchoolName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `SchoolWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `State_SchoolID` tinytext, `State_DistrictID` tinytext, `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `BuildingLowestGradeLevel` tinytext NOT NULL, `BuildingHighestGradeLevel` tinytext NOT NULL, PRIMARY KEY (`TContent_ID`,`SchoolDistrict_NCES_ID`,`NCES_ID`), UNIQUE KEY `NCES_ID` (`NCES_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
					var dbCreateTableSchoolBuildingsResults = dbCreateTableSchoolBuildings.execute();
				} else {
				 writedump(dbCreateTableSchoolBuildingsResults.getResult());
				 abort;
				}
			}

			var dbCheckTableDeviceTypes = new query();
			dbCheckTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableDeviceTypes.setSQL("Show Tables LIKE 'pDeviceTypes'");
			var dbCheckTableDeviceTypesResults = dbCheckTableDeviceTypes.execute();

			if (dbCheckTableDeviceTypesResults.getResult().recordcount eq 0) {
				// Since the Database Table does not exists, Lets Create it
				var dbCreateTableDeviceTypes = new query();
				dbCreateTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTableDeviceTypes.setSQL("CREATE TABLE `pDeviceTypes` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `DeviceName` tinytext NOT NULL, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `Active` char(1) NOT NULL DEFAULT '1', PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
				var dbCreateTableDeviceTypesResults = dbCreateTableDeviceTypes.execute();
			} else {
				// Database Table Exists, We must Drop it to create it again
				var dbDropTableDeviceTypes = new query();
				dbDropTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableDeviceTypes.setSQL("DROP TABLE pDeviceTypes");
				var dbDropTableDeviceTypesResults = dbDropTableDeviceTypes.execute();

				if (len(dbDropTableDeviceTypesResults.getResult()) eq 0) {
					var dbCreateTableDeviceTypes = new query();
					dbCreateTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
					dbCreateTableDeviceTypes.setSQL("CREATE TABLE `pDeviceTypes` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `DeviceName` tinytext NOT NULL, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `Active` char(1) NOT NULL DEFAULT '1', PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
					var dbCreateTableDeviceTypesResults = dbCreateTableDeviceTypes.execute();
				} else {
				 writedump(dbCreateTableDeviceTypesResults.getResult());
				 abort;
				}
			}

			var dbCheckTableUserMatrix = new query();
			dbCheckTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableUserMatrix.setSQL("Show Tables LIKE 'pUserMatrix'");
			var dbCheckTableUserMatrixResults = dbCheckTableUserMatrix.execute();

			if (dbCheckTableUserMatrixResults.getResult().recordcount eq 0) {
				// Since the Database Table does not exists, Lets Create it
				var dbCreateTableUserMatrix = new query();
				dbCreateTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTableUserMatrix.setSQL("CREATE TABLE `pUserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `School_District` int(11) NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, PRIMARY KEY (`TContent_ID`) )  ENGINE=InnoDB DEFAULT CHARSET=latin1;");
				var dbCreateTableUserMatrixResults = dbCreateTableUserMatrix.execute();
			} else {
				// Database Table Exists, We must Drop it to create it again
				var dbDropTableUserMatrix = new query();
				dbDropTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableUserMatrix.setSQL("DROP TABLE pUserMatrix");
				var dbDropTableUserMatrixResults = dbDropTableUserMatrix.execute();

				if (len(dbDropTableUserMatrixResults.getResult()) eq 0) {
					var dbCreateTableUserMatrix = new query();
					dbCreateTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
					dbCreateTableUserMatrix.setSQL("CREATE TABLE `pUserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `School_District` int(11) NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, PRIMARY KEY (`TContent_ID`) )  ENGINE=InnoDB DEFAULT CHARSET=latin1;");
					var dbCreateTableUserMatrixResults = dbCreateTableUserMatrix.execute();
				} else {
				 writedump(dbCreateTableUserMatrixResults.getResult());
				 abort;
				}
			}

			var dbCheckTableZipCodes = new query();
			dbCheckTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableZipCodes.setSQL("Show Tables LIKE 'pZipCodes'");
			var dbCheckTableZipCodesResults = dbCheckTableZipCodes.execute();

			if (dbCheckTableZipCodesResults.getResult().recordcount eq 0) {
				// Since the Database Table does not exists, Lets Create it
				var dbCreateTableZipCodes = new query();
				dbCreateTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTableZipCodes.setSQL("CREATE TABLE `pZipCodes` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL, `ZipCode` char(5) NOT NULL, `City` varchar(64) NOT NULL, `State` char(2) NOT NULL, `Latitude` decimal(9,6) DEFAULT NULL, `Longitude` decimal(9,6) DEFAULT NULL, `Timezone` char(2) DEFAULT NULL, `DST` char(1) DEFAULT NULL, `StateFIPS` char(2) NOT NULL, PRIMARY KEY (`TContent_ID`,`ZipCode`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableZipCodesResults = dbCreateTableZipCodes.execute();
			} else {
				// Database Table Exists, We must Drop it to create it again
				var dbDropTableZipCodes = new query();
				dbDropTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableZipCodes.setSQL("DROP TABLE pZipCodes");
				var dbDropTableZipCodesResults = dbDropTableZipCodes.execute();

				if (len(dbDropTableZipCodesResults.getResult()) eq 0) {
					var dbCreateTableZipCodes = new query();
					dbCreateTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
					dbCreateTableZipCodes.setSQL("CREATE TABLE `pZipCodes` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL, `ZipCode` char(5) NOT NULL, `City` varchar(64) NOT NULL, `State` char(2) NOT NULL, `Latitude` decimal(9,6) DEFAULT NULL, `Longitude` decimal(9,6) DEFAULT NULL, `Timezone` char(2) DEFAULT NULL, `DST` char(1) DEFAULT NULL, `StateFIPS` char(2) NOT NULL, PRIMARY KEY (`TContent_ID`,`ZipCode`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
					var dbCreateTableZipCodesResults = dbCreateTableZipCodes.execute();
				} else {
				 writedump(dbCreateTableZipCodesResults.getResult());
				 abort;
				}
			}
		</cfscript>

	</cffunction>

	<cffunction name="update" output="false" returntype="any">
		<cfset application.appInitialized = false>
	</cffunction>

	<cffunction name="delete" output="false" returntype="any">
		<cfset application.appInitialized = false>

		<cfscript>
			var dbCheckTableSchoolDistricts = new query();
			dbCheckTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableSchoolDistricts.setSQL("Show Tables LIKE 'pSchoolDistricts'");
			var dbCheckTableSchoolDistrictsResults = dbCheckTableSchoolDistricts.execute();

			if (len(dbCheckTableSchoolDistrictsResults.getResult()) neq 0) {
				var dbDropTableSchoolDistricts = new query();
				dbDropTableSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableSchoolDistricts.setSQL("DROP TABLE pSchoolDistricts");
				var dbDropTableSchoolDistrictsResults = dbDropTableSchoolDistricts.execute();

				if (len(dbDropTableSchoolDistrictsResults.getResult()) neq 0) {
					writedump(dbDropTableSchoolDistrictsResults.getResult());
					abort;
				}
			}

			var dbCheckTableSchoolBuildings = new query();
			dbCheckTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableSchoolBuildings.setSQL("Show Tables LIKE 'pSchoolBuildings'");
			var dbCheckTableSchoolBuildingsResult = dbCheckTableSchoolBuildings.execute();

			if (len(dbCheckTableSchoolBuildingsResult.getResult()) neq 0) {
				var dbDropTableSchoolBuildings = new query();
				dbDropTableSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableSchoolBuildings.setSQL("DROP TABLE pSchoolBuildings");
				var dbDropTableSchoolBuildingsResults = dbDropTableSchoolBuildings.execute();

				if (len(dbDropTableSchoolBuildingsResults.getResult()) neq 0) {
					writedump(dbDropTableSchoolBuildingsResults.getResult());
					abort;
				}
			}

			var dbCheckTableDeviceTypes = new query();
			dbCheckTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableDeviceTypes.setSQL("Show Tables LIKE 'pDeviceTypes'");
			var dbCheckTableDeviceTypesResults = dbCheckTableDeviceTypes.execute();

			if (len(dbCheckTableDeviceTypesResults.getResult()) neq 0) {
				var dbDropTableDeviceTypes = new query();
				dbDropTableDeviceTypes.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableDeviceTypes.setSQL("DROP TABLE pDeviceTypes");
				var dbDropTableDeviceTypesResults = dbDropTableDeviceTypes.execute();

				if (len(dbDropTableDeviceTypesResults.getResult()) neq 0) {
					writedump(dbDropTableDeviceTypesResults.getResult());
					abort;
				}
			}


			var dbCheckTableUserMatrix = new query();
			dbCheckTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableUserMatrix.setSQL("Show Tables LIKE 'pUserMatrix'");
			var dbCheckTableUserMatrixResults = dbCheckTableUserMatrix.execute();

			if (len(dbCheckTableUserMatrixResults.getResult()) neq 0) {
				var dbDropTableUserMatrix = new query();
				dbDropTableUserMatrix.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableUserMatrix.setSQL("DROP TABLE pUserMatrix");
				var dbDropTableUserMatrixResults = dbDropTableUserMatrix.execute();

				if (len(dbDropTableUserMatrixResults.getResult()) neq 0) {
					writedump(dbDropTableUserMatrixResults.getResult());
					abort;
				}
			}

			var dbCheckTableZipCodes = new query();
			dbCheckTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
			dbCheckTableZipCodes.setSQL("Show Tables LIKE 'pZipCodes'");
			var dbCheckTableZipCodesResults = dbCheckTableZipCodes.execute();

			if (len(dbCheckTableZipCodesResults.getResult()) neq 0) {
				var dbDropTableZipCodes = new query();
				dbDropTableZipCodes.setDatasource("#application.configBean.getDatasource()#");
				dbDropTableZipCodes.setSQL("DROP TABLE pZipCodes");
				var dbDropTableZipCodesResults = dbDropTableZipCodes.execute();

				if (len(dbDropTableZipCodesResults.getResult()) neq 0) {
					writedump(dbDropTableZipCodesResults.getResult());
					abort;
				}
			}

		</cfscript>
	</cffunction>

</cfcomponent>