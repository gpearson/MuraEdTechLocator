<!---

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
<cfinclude template="../includes/fw1config.cfm" />
<cfoutput><plugin>
	<name>#variables.framework.package#</name>
	<package>#variables.framework.package#</package>
	<directoryFormat>packageOnly</directoryFormat>
	<provider>Graham Pearson</provider>
	<providerURL>http://www.yourcfpro.com</providerURL>
	<loadPriority>5</loadPriority>
	<version>#variables.framework.packageVersion#</version>
	<category>Application</category>
	<ormcfclocation />
	<customtagpaths />
	<mappings />
	<settings />
	<eventHandlers>
		<eventHandler event="onApplicationLoad" component="includes.eventHandler" persist="false" />
	</eventHandlers>
	<displayobjects location="global">
		<displayobject name="Display Public Locator" displaymethod="ViewPublicLocator" component="includes.displayObjects" persist="false" />
	</displayobjects>
</plugin></cfoutput>