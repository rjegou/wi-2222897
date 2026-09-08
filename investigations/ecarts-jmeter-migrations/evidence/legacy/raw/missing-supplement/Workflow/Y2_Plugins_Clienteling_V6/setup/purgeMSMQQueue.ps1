param(
[Parameter(Mandatory=$True,Position=1)]
[string]$queueName)

[Reflection.Assembly]::LoadWithPartialName('System.Messaging');
if ([System.Messaging.MessageQueue]::Exists($queueName))
{
	$queue=new-object System.Messaging.MessageQueue $queueName;
	$queue.Purge();
}