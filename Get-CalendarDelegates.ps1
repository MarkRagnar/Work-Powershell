
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter 
ForEach-Object $Mailbox in $Mailboxes {
    $Calendar = $Mailbox.PrimarySmtpAddress.ToString() + ":\Calendar"
    Get-MailboxFolderPermission $Calendar | Export-Csv "C:\.CalendarPermissions\$mailbox.csv"
}

