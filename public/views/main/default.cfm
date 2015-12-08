<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2014 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfoutput>
	<cfif isDefined("URL.SentInquiry") and isDefined("URL.StateToPopulate")>
		<p class="alert-box success">Your Inquiry to have another state populated with information has been sent. You will receive an email back when you are able to go through the process to share your 1:1 School Inititive</p>
	</cfif>
	<p><div align="center"><h5>To view 1:1 program initiatives in a state, simply click on an active state.</h5></div></p>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/swfobject.js"></script>
	<div id="swf" align="center">
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
		<script type="text/javascript">
			// <![CDATA[
				var soFlash = new SWFObject("/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/flash/usaMap.swf", "theVars", "950", "600", "0", "##FFFFFF");
				soFlash.addParam("allowFullScreen", "false");
				soFlash.addVariable("xmlPath", "/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/flash/usaMapSettings.xml");
				soFlash.write("swf");
			// ]]>
		</script>
	</div>
</cfoutput>