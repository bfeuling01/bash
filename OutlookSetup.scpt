--- Configured by Bryan Feuling and Sean Boult
--- Modified version of TalkingMoose Script

-- prevent the script running twice?

tell application "Finder"
	if exists POSIX file "/usr/local/ti/outlook_setup_done" then
		tell me to quit
	end if
end tell

do shell script "/usr/bin/touch /usr/local/ti/outlook_setup_done"

--------------- Exchange Server settings ----------------------

property useKerberos : false
-- Set this to true only if Macs in your environment are bound
-- to Active Directory and your network is properly configured.

property ExchangeServer : "ServerName"
-- Address of your organization's Exchange server.

property ExchangeServerRequiresSSL : true
-- True for most servers.

property ExchangeServerSSLPort : 443
-- If ExchangeServerRequiresSSL is true set the port to 443.
-- If ExchangeServerRequiresSSL is false set the port to 80.
-- Use a different port number only if your administrator instructs you.

--ldap.directory.ti.com -b \"ou=person,o=ti,c=us\"
property DirectoryServer : ""
-- dlead05.ent.ti.com
-- Address of an internal Global Catalog server (a type of Windows domain controller).
-- The LDAP server in a Windows network will be a Global Catalog server,
-- which is separate from the Exchange Server.

property DirectoryServerRequiresAuthentication : false
-- This will almost always be true.

property DirectoryServerRequiresSSL : false
-- This will almost always be true.

property DirectoryServerSSLPort : 3268
-- If DirectoryServerRequiresSSL is true set the port to 3269.
-- If DirectoryServerRequiresSSL is false set the port to 3268.
-- Use a different port number only if your Exchange administrator instructs you.

property DirectoryServerMaximumResults : 1000
-- When searching the Global Catalog server, this number determines
-- the maximum number of entries to display.

property DirectoryServerSearchBase : ""
-- dc=ent,dc=ti,dc=com
-- example: "cn=users,dc=domain,dc=com"
-- Usually, this is empty.


--------------- For Active Directory users ---------------------

property getUserInformationFromActiveDirectory : false
-- If Macs are bound to Active Directory they can probably use
-- dscl to return the current user's email address, phone number, title, etc.
-- Use Active Directory when possible, otherwise complete the next section.


--------------- For non Active Directory users ---------------

property domainName : "DomainName"
-- Complete this only if not using Active Directory to get user information.
-- The part of your organization's email address following the @ symbol.

property emailFormat : 1
-- Complete this only if not using Active Directory to get user information.
-- When Active Directory is unavailable to determine a user's email address,
-- this script will attempt to parse it from the display name of the user's login.

-- Describe your organization's email format:
-- 1: Email format is first.last@domain.com
-- 2: Email format is first@domain.com
-- 3: Email format is flast@domain.com (first name initial plus last name)
-- 4: Email format is shortName@domain.com

property displayName : 2
-- Complete this only if not using Active Directory to get user information.
-- Describe how the user's display name appears at the bottom of the menu
-- when clicking the Apple menu (Log Out Joe Cool... or Log Out Cool, Joe...).
-- 1: Display name appears as "Last, First"
-- 2: Display name appears as "First Last"

property domainPrefix : ""
-- Optionally append a NetBIOS domain name to the beginning of the user's short name.
-- Be sure to use two backslashes when adding a name.
-- Example: Use "TALKINGMOOSE\\" to set user name "TALKINGMOOSE\username".


--------------- User Experience -------------------------------

property verifyEMailAddress : false
-- If set to "true", a dialog asks the user to confirm his email address.

property verifyServerAddress : false
-- If set to "true", a dialog asks the user to confirm his Exchange server address.

property displayDomainPrefix : false
-- If set to "true", the username appears as "DOMAIN\username".
-- Otherwise, the username appears as "username".

property downloadHeadersOnly : false
-- If set to "true", only email headers are downloaded into Outlook.
-- This takes much less time to sync but a user must be online
-- to download and view messages.

property hideOnMyComputerFolders : true
-- If set to "true", hides local folders.
-- A single Exchange account should do this by default.

property unifiedInbox : false
-- If set to "true", turns on the Group Similar Folders feature
-- in Outlook menu > Preferences > General.

property disableAutodiscover : false
-- If set to "true", disables Autodiscover functionality
-- for the Exchange account. Not recommended for mobile devices
-- that may connect to an internal Exchange server address and
-- connect to a different external Exchange server address.

property errorMessage : "Outlook's setup for your Exchange account failed. Please contact the Help Desk for assistance."
-- Customize this error message for your users in case their account setup fails

--------------------------------------------
-- End network, server and preferences
--------------------------------------------

--------------------------------------------
-- Begin log file setup
--------------------------------------------

-- create the log file in the current user's Logs folder

writeLog("Starting Exchange account setup...")
writeLog("Script: " & name of me)
writeLog(return)

--------------------------------------------
-- End log file setup
--------------------------------------------

--------------------------------------------
-- Begin logging script properties
--------------------------------------------

writeLog("Setup properties...")
writeLog("Use Kerberos: " & useKerberos)
writeLog("Exchange Server: " & ExchangeServer)
writeLog("Exchange Server Requires SSL: " & ExchangeServerRequiresSSL)
writeLog("Exchange Server Port: " & ExchangeServerSSLPort)
writeLog("Directory Server: " & DirectoryServer)
writeLog("Directory Server Requires Authentication: " & DirectoryServerRequiresAuthentication)
writeLog("Directory Server Requires SSL: " & DirectoryServerRequiresSSL)
writeLog("Directory Server SSL Port: " & DirectoryServerSSLPort)
writeLog("Directory Server Maximum Results: " & DirectoryServerMaximumResults)
writeLog("Directory Server Search Base: " & DirectoryServerSearchBase)
writeLog("Get User Information from Active Directory: " & getUserInformationFromActiveDirectory)
writeLog(return)

if getUserInformationFromActiveDirectory is false then
	writeLog("Domain Name: " & domainName)
	writeLog("Email format: " & emailFormat)
	writeLog("Display Name: " & displayName)
	writeLog("Domain Prefix: " & domainPrefix)
	writeLog(return)
end if

writeLog("Verify Email Address: " & verifyEMailAddress)
writeLog("Verify Server Address: " & verifyServerAddress)
writeLog("Display Domain Prefix: " & displayDomainPrefix)
writeLog("Download Headers Only: " & downloadHeadersOnly)
writeLog("Hide On My Computer Folders: " & hideOnMyComputerFolders)
writeLog("Unified Inbox: " & unifiedInbox)
writeLog("Disable Autodiscover: " & disableAutodiscover)
writeLog("Error Message text: " & errorMessage)
writeLog(return)

--------------------------------------------
-- End logging script properties
--------------------------------------------

--------------------------------------------
-- Begin collecting user information
--------------------------------------------

-- attempt to read information from Active Directory for the Me Contact record

set userFirstName to ""
set userLastName to ""
set userDepartment to ""
set userOffice to ""
set userCompany to ""
set userWorkPhone to ""
set userMobile to ""
set userFax to ""
set userTitle to ""
set userStreet to ""
set userCity to ""
set userState to ""
set userPostalCode to ""
set userCountry to ""
set userWebPage to ""

set userShortName to short user name of (system info)
set GetUserInfo to "ldapsearch -LLL -x -h ldap.directory.ti.com -b \"ou=person,o=ti,c=us\" idnumber=" & userShortName & " cn mail"

set UserInfo to do shell script GetUserInfo

repeat with aLine from 1 to count of paragraphs in UserInfo
	if paragraph aLine of UserInfo begins with "cn:" then
		set AppleScript's text item delimiters to ": "
		set userFullName to text item 2 of paragraph aLine of UserInfo
		set AppleScript's text item delimiters to ": "
	else if paragraph aLine of UserInfo begins with "mail:" then
		set AppleScript's text item delimiters to ": "
		set emailAddress to text item 2 of paragraph aLine of UserInfo
		set AppleScript's text item delimiters to ": "
	end if
end repeat

--------------------------------------------
-- End collecting user information
--------------------------------------------

--------------------------------------------
-- Begin account setup
--------------------------------------------

tell application "Microsoft Outlook"
	activate

	--set working offline to true

	try
		set group similar folders to unifiedInbox
		my writeLog("Set Group Similar Folders to " & unifiedInbox & ": Successful.")
	on error
		my writeLog("Set Group Similar Folders to " & unifiedInbox & ": Failed.")
	end try

	try
		set hide on my computer folders to hideOnMyComputerFolders
		my writeLog("Set Hide On My Computer Folders to " & hideOnMyComputerFolders & ": Successful.")
	on error
		my writeLog("Set Hide On My Computer Folders to " & hideOnMyComputerFolders & ": Failed.")
	end try

	if verifyEMailAddress is true then
		set verifyEmail to display dialog "Please verify your email address is correct." default answer emailAddress with icon 1 with title "Outlook Exchange Setup" buttons {"Cancel", "Verify"} default button {"Verify"}
		set emailAddress to text returned of verifyEmail
		my writeLog("User verified email address as " & emailAddress & ".")
	end if

	if verifyServerAddress is true then
		set verifyServer to display dialog "Please verify your Exchange Server name is correct." default answer ExchangeServer with icon 1 with title "Outlook Exchange Setup" buttons {"Cancel", "Verify"} default button {"Verify"}
		set ExchangeServer to text returned of verifyServer
		my writeLog("User verified server address as " & ExchangeServer & ".")
	end if

	-- create the Exchange account
	-- try
	set newExchangeAccount to make new exchange account with properties ¬
		{name:"Mailbox - " & userFullName, user name:domainPrefix & userShortName, full name:userFullName, email address:emailAddress, server:ExchangeServer, use ssl:ExchangeServerRequiresSSL, port:ExchangeServerSSLPort, ldap server:DirectoryServer, ldap needs authentication:DirectoryServerRequiresAuthentication, ldap use ssl:DirectoryServerRequiresSSL, ldap max entries:DirectoryServerMaximumResults, ldap search base:DirectoryServerSearchBase, receive partial messages:downloadHeadersOnly, background autodiscover:disableAutodiscover}
	my writeLog("Create Exchange account: Successful.")


	if useKerberos is true then
		try
			set use kerberos authentication of newExchangeAccount to useKerberos
			set principal of newExchangeAccount to userKerberosRealm
			my writeLog("Set Kerberos authentication: Successful.")
		on error

			my writeLog("Set Kerberos authentication: Failed.")

			display dialog errorMessage & return & return & "Unable to set Exchange account to use Kerberos." with icon stop buttons {"OK"} default button {"OK"} with title "Outlook Exchange Setup"
			error number -128

		end try
	end if

	try
		-- The Me Contact record is automatically created with the first account.
		-- Set the first name, last name, email address and other information using Active Directory.

		set first name of me contact to userFirstName
		set last name of me contact to userLastName
		set email addresses of me contact to {address:emailAddress, type:work}
		set department of me contact to userDepartment
		set office of me contact to userOffice
		set company of me contact to userCompany
		set business phone number of me contact to userWorkPhone
		set mobile number of me contact to userMobile
		set business fax number of me contact to userFax
		set job title of me contact to userTitle
		set business street address of me contact to userStreet
		set business city of me contact to userCity
		set business state of me contact to userState
		set business zip of me contact to userPostalCode
		set business country of me contact to userCountry
		set business web page of me contact to userWebPage
		my writeLog("Populate Me Contact information: Successful.")
	on error
		my writeLog("Populate Me Contact information: Failed.")
	end try

	delay 5

	set working offline to false


end tell

writeLog("Attempting to run the cleanup folder command")
do shell script "/bin/launchctl unload /usr/local/ti/outlook/com.ti.outlook.plist; /bin/rm -f ~/Library/LaunchAgents/com.ti.outlook.plist"
writeLog("Cleanup finished!")
--------------------------------------------
-- End account setup
--------------------------------------------

on writeLog(logMessage)
	set logFile to (path to home folder as string) & "Library:Logs:outlook_setup.log"
	set rightNow to short date string of (current date) & " " & time string of (current date) & tab
	if logMessage is return then
		set logInfo to return
	else
		set logInfo to rightNow & logMessage & return
	end if
	set openLogFile to open for access file logFile with write permission
	write logInfo to openLogFile starting at eof
	close access file logFile
end writeLog

--------------------------------------------
-- End script handlers
--------------------------------------------5.4.0

--------------------------------------------
-- Begin script cleanup
--------------------------------------------
