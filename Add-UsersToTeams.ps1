# Connect-MicrosoftTeams
$emails = @(
"Email@contoso.com",
"Email2@contoso.com"
)

# Team ID (replace with your actual Team ID) This can help [ get-team -DisplayName "Technical" ]
$teamId = "GUID"

$emails | ForEach-Object {
  $user = $_

 function UserExists($user, $existingMembers) {
   $existingMembers.UserPrincipalName -contains $user 
   }

  # Connect-MicrosoftTeams
   $existingMembers = Get-TeamUser -GroupId $teamId | Select-Object UserPrincipalName
   if (!(UserExists $user -ExistingMembers $existingMembers)) {

  # Add user to the Team (excluding existing members - uncomment above block for this)
  try {
    Add-TeamUser -GroupId $teamId -User $user
    Write-Host "Added user $user to the Team."
  } catch {
    Write-Warning "Error adding user $user : $($_.Exception.Message)"
  }

  # Uncomment the following line for confirmation prompt (even if user exists)
  # Write-Host "Do you want to continue adding users? (Y/N)" -NoNewline
  # $continue = Read-Host
  # if ($continue -ne "Y") {
  #   break
  # }

   }  # Uncomment the closing curly brace for the existing member check
}

# Function to check if user already exists (optional - uncomment above block)
