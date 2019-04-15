$Server = "server"

$HTTPS_FQDN = "mail.company.com"

Get-OWAVirtualDirectory -Server $Server | Set-OWAVirtualDirectory -InternalURL   "https://$($HTTPS_FQDN)/owa" -ExternalURL   "https://$($HTTPS_FQDN)/owa"

Get-ECPVirtualDirectory -Server $Server | Set-ECPVirtualDirectory -InternalURL   "https://$($HTTPS_FQDN)/ecp" -ExternalURL   "https://$($HTTPS_FQDN)/ecp"

Get-OABVirtualDirectory -Server $Server | Set-OABVirtualDirectory -InternalURL   "https://$($HTTPS_FQDN)/oab" -ExternalURL   "https://$($HTTPS_FQDN)/oab"

Get-ActiveSyncVirtualDirectory -Server $Server | Set-ActiveSyncVirtualDirectory -InternalURL "https://$($HTTPS_FQDN)/Microsoft-Server-ActiveSync"   -ExternalURL "https://$($HTTPS_FQDN)/Microsoft-Server-ActiveSync"

Get-WebServicesVirtualDirectory -Server $Server | Set-WebServicesVirtualDirectory -InternalURL "https://$($HTTPS_FQDN)/EWS/Exchange.asmx"   -ExternalURL "https://$($HTTPS_FQDN)/EWS/Exchange.asmx"

Get-MapiVirtualDirectory -Server $Server | Set-MapiVirtualDirectory -InternalURL   "https://$($HTTPS_FQDN)/mapi" -ExternalURL   https://$($HTTPS_FQDN)/mapi