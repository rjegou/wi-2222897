param(
[Parameter(Mandatory = $true, Position = 0)] [String] $applicationPlatform,
[Parameter(ValueFromRemainingArguments = $true)] [String[]] $computerNames
)

$assembly = [Reflection.Assembly]::LoadWithPartialName('System.Messaging');

Function SetPermissions($queue, $computerName)
{
	# Les droits d'accès Set et Allow correspondent à :
	# - Recevoir un message
	# - Message visuel
	# - Recevoir le message journal
	# - Envoyer un message
	# - Obtenir les propriétés
	# - Obtenir les autorisations
	$queue.SetPermissions($computerName, [System.Messaging.MessageQueueAccessRights]::GenericRead, [System.Messaging.AccessControlEntryType]::Set);
	$queue.SetPermissions($computerName, [System.Messaging.MessageQueueAccessRights]::GenericWrite, [System.Messaging.AccessControlEntryType]::Allow);
	Write-Host "    => Permissions assigned for '$computerName'"
}

Function SetPermissionsOnQueue($queue, $computerNames)
{
	# Assignation des droits complets au groupe local Administateurs (sid = S-1-5-32-544).
	$objSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
	if ($objSID)
	{
		$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
		$createdQueue.SetPermissions( $objUser.Value, [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
		Write-Host "    => Permissions assigned for '$objUser'"
	}
	else
	{
		Write-Host "Queue '$queueName': no administrators group to grant full rights on created queue"
	}

	# Assignation des droits "utilisateurs" à la machine locale
	$computerObject = (gwmi win32_computersystem);
	$localComputerName = $computerObject.Domain + "\" + $computerObject.Name + "$";
	SetPermissions $queue $localComputerName;

	# Assignation des droits "utilisateurs" aux machines spécifiées
    if ($computerNames)
    {
    	ForEach ($computerName in $computerNames)
	   {
		  SetPermissions $queue ($computerName + "$");
	   }
    }
}

Function CreateQueueIfRequired($queueName, $qlabel)
{
	# Création de la file si nécessaire.
	if (![System.Messaging.MessageQueue]::Exists($queueName))
	{
		# Le fait de créer la file depuis cette machine assigne les droits suivants automatiquement à la machine locale :
		# - Obtenir les propriétés
		# - Obtenir les autorisations
		$createdQueue = [System.Messaging.MessageQueue]::Create($queueName)

		# Description de la file msmq
		$createdQueue.Label =  $qlabel

		Write-Host "Queue '$queueName' created"
	}
	else
	{
		$createdQueue = New-Object -typename System.Messaging.MessageQueue $queueName
		Write-Host "Queue '$queueName' already exists"
	}
    
    # Ajout des permissions "utilisateur" sur la file
	SetPermissionsOnQueue $createdQueue $computerNames
}

Write-Host ""
Write-Host "********************************************************************************"
Write-Host "*** CreateMSMQQueue.ps1"
Write-Host "********************************************************************************"
Write-Host "*** Application platform ('applicationPlatform') = $applicationPlatform"
Write-Host "*** Computer names (Other arguments) = $computerNames"
Write-Host "********************************************************************************"
Write-Host ""

# Le script crée une queue "locale privée".
$reportQueueName = ".\Private$\" + $applicationPlatform + "Report";
$reportLabel = 	'Report service request - ' + $applicationPlatform;

$responseQueueName = $reportQueueName + "Response";
$responseLabel = 'Report service response - ' + $applicationPlatform;

CreateQueueIfRequired $reportQueueName $reportLabel
CreateQueueIfRequired $responseQueueName $responseLabel