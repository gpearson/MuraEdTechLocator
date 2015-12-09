<cfmail To="#getUserAccount.fName# #getUserAccount.lName# <#getUserAccount.Email#>" from="1 To 1 Schools Education <info@1to1schools.education>" subject="1:1 Schools Resource - Account Activation Confirmation Email" server="127.0.0.1">
<cfmailpart type="text/plain">
#getUserAccount.fName# #getUserAccount.lName#,

You have successfully activated your account on the 1:1 Schools Education Resource (www.1to1schools.education). You may now login with your email address as the username and the password you entered while creating your account.


Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getUserAccount.fName# #getUserAccount.lName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">You have successfully activated your account on the 1:1 Schools Education Resource (www.1to1schools.education). You may now login with your email address as the username and the password you entered while creating your account.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>