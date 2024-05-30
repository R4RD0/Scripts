# Import Teams module
Import-Module Teams

Connect-MicrosoftTeams 

# Get all Teams
$teams = Get-Team

# Create an empty array to store the output
$output = @()

# Check if user is an owner for each Team
foreach ($team in $teams) {
    $owners = Get-TeamUser -GroupId $team.GroupId -Role Owner
    $members = Get-TeamUser -GroupId $team.GroupId -Role Member
    $channels = Get-TeamChannel -GroupId $team.GroupId
    $siteUrl = Get-SPOSite -Identity $team.GroupId

    foreach ($channel in $channels) {
        $channelOwners = Get-TeamChannelUser -GroupId $team.GroupId -DisplayName $channel.DisplayName -Role Owner
        $channelMembers = Get-TeamChannelUser -GroupId $team.GroupId -DisplayName $channel.DisplayName -Role Member
        $channelSiteUrl = Get-SPOSite -Identity $channel.Id

        # Create a custom object for this team and add it to the output array
        $output += New-Object PSObject -Property @{
            "Team Name" = $team.DisplayName
            "SharePoint Site" = $siteUrl.Url
            "Team Owners" = $owners.User -join ', '
            "Team Members" = $members.User -join ', '
            "Channel Name" = $channel.DisplayName
            "Channel Owners" = $channelOwners.User -join ', '
            "Channel Members" = $channelMembers.User -join ', '
            "Channel SharePoint Site" = $channelSiteUrl.Url
        }
    }
}

# Export the output array to a CSV file
$output | Export-Csv -Path 'C:\path\to\output.csv' -NoTypeInformation