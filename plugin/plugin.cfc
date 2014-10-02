/*

This file is part of MuraFW1

Copyright 2010-2014 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
component persistent="false" accessors="true" output="false" extends="mura.plugin.plugincfc" {

	property name="config" type="any" default="";

	public any function init(any config='') {
		setConfig(arguments.config);
	}

	public void function install() {
		// triggered by the pluginManager when the plugin is INSTALLED.
		application.appInitialized = false;

		var dbCheckSchoolDistricts = new query();
		dbCheckSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
		dbCheckSchoolDistricts.setSQL("Show Tables LIKE 'pSchoolDistricts'");
		var dbCheckSchoolDistrictsResult = dbCheckSchoolDistricts.execute();
		if (dbCheckSchoolDistrictsResult.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateSchoolDistricts = new query();
			dbCreateSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
			dbCreateSchoolDistricts.setSQL("CREATE TABLE `pSchoolDistricts` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(8) NOT NULL, `DistrictName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `LowestGradeLevel` char(2) NOT NULL DEFAULT 'K', `HighestGradeLevel` char(2) NOT NULL DEFAULT '12', PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
			var dbCreateSchoolDistrictsResults = dbCreateSchoolDistricts.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropSchoolDistricts = new query();
			dbDropSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
			dbDropSchoolDistricts.setSQL("DROP TABLE pSchoolDistricts");
			var dbDropSchoolDistrictsResult = dbDropSchoolDistricts.execute();


			if (len(dbDropSchoolDistrictsResult.getResult()) eq 0) {
				var dbCreateSchoolDistricts = new query();
				dbCreateSchoolDistricts.setDatasource("#application.configBean.getDatasource()#");
				dbCreateSchoolDistricts.setSQL("CREATE TABLE `pSchoolDistricts` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(8) NOT NULL, `DistrictName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `LowestGradeLevel` char(2) NOT NULL DEFAULT 'K', `HighestGradeLevel` char(2) NOT NULL DEFAULT '12', PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
				var dbCreateSchoolDistrictsResults = dbCreateSchoolDistricts.execute();
			} else {
			 writedump(dbDropSchoolDistrictsResult.getResult());
			 abort;
			}
		}

		var dbCheckSchoolBuildings = new query();
		dbCheckSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
		dbCheckSchoolBuildings.setSQL("Show Tables LIKE 'pSchoolBuildings'");
		var dbCheckSchoolBuildingsResult = dbCheckSchoolBuildings.execute();
		if (dbCheckSchoolBuildingsResult.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateSchoolBuildings = new query();
			dbCreateSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
			dbCreateSchoolBuildings.setSQL("CREATE TABLE `pSchoolBuildings` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `SchoolDistrict_NCES_ID` char(10) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(12) NOT NULL, `SchoolName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `SchoolWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `State_SchoolID` tinytext, `State_DistrictID` tinytext, `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `BuildingLowestGradeLevel` char(2) NOT NULL DEFAULT 'K', `BuildingHighestGradeLevel` char(2) NOT NULL DEFAULT '12', PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`,`SchoolDistrict_NCES_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
			var dbCreateSchoolBuildingsResult = dbCreateSchoolDistricts.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbCheckSchoolBuildings = new query();
			dbCheckSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
			dbCheckSchoolBuildings.setSQL("DROP TABLE pSchoolBuildings");
			var dbCheckSchoolBuildingsResult = dbCheckSchoolBuildings.execute();

			if (len(dbCheckSchoolBuildingsResult.getResult()) eq 0) {
				var dbCreateSchoolBuildings = new query();
				dbCreateSchoolBuildings.setDatasource("#application.configBean.getDatasource()#");
				dbCreateSchoolBuildings.setSQL("CREATE TABLE `pSchoolBuildings` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `SchoolDistrict_NCES_ID` char(10) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `NCES_ID` char(12) NOT NULL, `SchoolName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `SchoolWebsite` tinytext, `ContactName` tinytext, `ContactPhoneNumber` tinytext, `ContactEmail` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `State_SchoolID` tinytext, `State_DistrictID` tinytext, `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` char(1) NOT NULL DEFAULT '1', `BuildingLowestGradeLevel` char(2) NOT NULL DEFAULT 'K', `BuildingHighestGradeLevel` char(2) NOT NULL DEFAULT '12', PRIMARY KEY (`TContent_ID`,`Site_ID`,`NCES_ID`,`SchoolDistrict_NCES_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
				var dbCreateSchoolBuildingsResult = dbCreateSchoolBuildings.execute();
			} else {
			 writedump(dbCreateSchoolBuildingsResult.getResult());
			 abort;
			}
		}

		var dbCheckDeviceType = new query();
		dbCheckDeviceType.setDatasource("#application.configBean.getDatasource()#");
		dbCheckDeviceType.setSQL("Show Tables LIKE 'pDeviceType'");
		var dbCheckDeviceTypeResult = dbCheckDeviceType.execute();
		if (dbCheckDeviceTypeResult.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateDeviceType = new query();
			dbCreateDeviceType.setDatasource("#application.configBean.getDatasource()#");
			dbCreateDeviceType.setSQL("CREATE TABLE `pDeviceType` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `DeviceName` tinytext NOT NULL, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `Active` char(1) NOT NULL DEFAULT '1', PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;");
			var dbCreateDeviceTypeResult = dbCreateDeviceType.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbCheckDeviceType = new query();
			dbCheckDeviceType.setDatasource("#application.configBean.getDatasource()#");
			dbCheckDeviceType.setSQL("DROP TABLE pDeviceType");
			var dbCheckDeviceTypeResult = dbCheckDeviceType.execute();

			if (len(dbCheckDeviceTypeResult.getResult()) eq 0) {
				var dbCreateDeviceType = new query();
				dbCreateDeviceType.setDatasource("#application.configBean.getDatasource()#");
				dbCreateDeviceType.setSQL("CREATE TABLE `pDeviceType` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `DeviceName` tinytext NOT NULL, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `Active` char(1) NOT NULL DEFAULT '1', PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;");
				var dbCreateDeviceTypeResult = dbCreateDeviceType.execute();
			} else {
			 writedump(dbCreateDeviceTypeResult.getResult());
			 abort;
			}
		}







		/*var dbCheckTableRegistrations = new query();




			*/

			/*
			 * inserteFacilityRows = arrayNew(1);
			 * inserteFacilityRows[1] = "'#Session.SiteID#', 'Northern Indiana ESC', '56535 Magnetic Dr', 'Mishawaka', 'IN', '46545', '', '(574)254-0111', 'http://www.niesc.k12.in.us', 'Ted Chittum', '574-254-0111', 'tchittum@niesc.k12.in.us', '2013-09-06 14:50:50', '2013-09-07 14:48:33', 'admin', 1, '41.6729735', '-86.1288432', 'Penn', 'Indiana', 'US', null, null, null, null, null, null, 1, 'S'";
			 * inserteFacilityRows[2] = "'#Session.SiteID#', 'Black Squirrel Golf Course', '1017 Larimer Dr', 'Goshen', 'IN', '46526', '', '(574)533-1828', '', 'Randy', '', '', '2013-09-10 08:46:47', '2013-09-10 08:46:48', 'admin', 1, '41.5793580', '-85.8562770', 'Elkhart', 'Indiana', 'US', null, null, null, null, null, null, 1, 'B'";
			 * inserteFacilityRows[3] = "'#Session.SiteID#', 'Christo\'s Banquet Center', '850 Lincolnway E', 'Plymouth', 'IN', '46563', '', '(574)935-9666', '', '', '', '', '2013-09-10 11:33:15', '2013-09-10 11:33:15', 'admin', 1, '41.3426657', '-86.2986407', 'Center', 'Indiana', 'US', null, null, null, null, null, null, 1, 'B'";
			 *
			 **/

			 /*
			  * Figure out how to do a cfloop in cfscript
			  *
			  * TestList = '1,2,3,4,5,6,7';
			  * for (i=0; i<ListLen(TestList); i++) {
			  	* command goes here
			  	* value = ListGetAt(TestList,i);
			  	* }
			  	*
			  * Figure out how to do a cfquery in cfscript
			  * <cfloop array="#inserteFacilityRows#" index="i">
			  * queryObj = new Query();
			  * queryObj.setDatasource('cfartgallery');
			  * queryObj.addParam(name="mediaId",value="1",cfsqltype="numeric");
			  * result = queryObj.execute(sql="select ArtName from art where mediaId = :mediaId");
			  * queryObj.clearParams();
			  *
			  * or
			  * queryObj.setName("qListOfArts");
			  * queryObj.addParam(name="price",value="32000",cfsqltype="NUMERIC");
			  * ueryObj.addParam(name="mediaid",value="1",cfsqltype="NUMERIC");
			  * queryObj.addParam(name="isSold",value="0",cfsqltype="SMALLINT");
			  * result = queryObj.execute(sql="SELECT artname,description,price FROM Art WHERE mediaId = :mediaid and isSold = :isSold and price > :price");
			  * qListOfArts = result.getResult();
			  * metaInfo = result.getPrefix();
			  * queryObj.clearParams();
			  * 			  *
			  * <cfquery name="insertData" datasource="#Application.configBean.getDatasource()#">
			  * Insert into eFacility(Site_ID, FacilityName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, BusinessWebsite, ContactName, ContactPhoneNumber, ContactEmail, dateCreated, lastUpdated, lastUpdateBy, isAddressVerified, GeoCode_Latitude, GeoCode_Longitude, GeoCode_Township, GeoCode_StateLongName, GeoCode_CountryShortName, GeoCode_Neighborhood, USPS_CarrierRoute, USPS_CheckDigit, USPS_DeliveryPoint, PhysicalLocationCountry, PhysicalCountry, Active, FacilityType)
			  * values(#i#)
			  * </cfquery>
			  * </cfloop>
			  **/
	}

	public void function update() {
		// triggered by the pluginManager when the plugin is UPDATED.
		application.appInitialized = false;
	}

	public void function delete() {
		// triggered by the pluginManager when the plugin is DELETED.
		application.appInitialized = false;
	}

}