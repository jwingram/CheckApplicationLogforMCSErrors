######################
# Title: CheckApplicationLogforMCSErrors.ps1
# Author: Jwingram
# Date: 09/21/15
# Description: Powershell Script to checks the Windows Application Event logs for errors specific to the MCS Application
######################

$emailFrom = "FROM EMAIL ADDRESS"
$emailTo = "TO EMAIL ADDRESS"
$subject = "MCS Application Error"
$smtpServer = "SMTP SERVER"

$sname=$myInvocation.MyCommand.Definition

#Future use to get the last real run time in Scheduled tasks
#[string]$LastRunTime=schtasks.exe /query /tn CheckApplicationLogforMCSErrors /fo LIST /v | select-string -Pattern "Last Run Time:"
#[datetime]$lastRunTime=$lastRunTime.trimstart("Last Run Time:")
$lastRunTime=get-date
$lastRunTime=$lastRunTime.addminutes(-30)

$errorMessage=Get-WinEvent -FilterHashtable @{Logname="Application"; ProviderName="Application Error"; Data="MCSFaxServer4.exe"; StartTime=$lastRunTime} -erroraction 'silentlycontinue'

if ($errorMessage -ne $null)
{
  $body+= "There is a new error that needs attention. The MCS application may have stopped.<font color=red>"
  $body+= "<br><br>Error Time: " + $errormessage.TimeCreated + "<br>ProviderName: " + $errormessage.providername + "<br>ID: " + $errormessage.Id + "<br>Message: " +$errormessage.message
  $body+="<font color=black><br><br>  Please attempt to restart the application.<br><br><p style=`"font-size:x-small;`">*****************************<br>This is an automated script located at $sname running on $env:computername as $env:username"  
  
  send-mailmessage -to $emailTo -from $emailFrom -subject $subject -smtpserver $smtpServer -body $body -bodyashtml
}