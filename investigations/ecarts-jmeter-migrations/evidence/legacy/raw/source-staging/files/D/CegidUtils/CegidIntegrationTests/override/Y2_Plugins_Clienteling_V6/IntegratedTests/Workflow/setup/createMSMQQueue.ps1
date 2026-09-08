param(
[Parameter(Mandatory=$True,Position=1)]
[string]$queueName)

[Reflection.Assembly]::LoadWithPartialName('System.Messaging');
if (![System.Messaging.MessageQueue]::Exists($queueName))
{
	$queue=[System.Messaging.MessageQueue]::Create($queueName);
	$queue.UseJournalQueue=$TRUE;
	$queue.Label=$queueName;
	$queue.MaximumJournalSize=10000;

	# set permissions
	$computerObject = (gwmi win32_computersystem);
	$computername = $computerObject.Domain + "\" + $computerObject.Name + "$";
	$queue.SetPermissions($computername, [System.Messaging.MessageQueueAccessRights]::GenericRead, [System.Messaging.AccessControlEntryType]::Set);
	$queue.SetPermissions($computername, [System.Messaging.MessageQueueAccessRights]::GenericWrite, [System.Messaging.AccessControlEntryType]::Allow);
}