# Do the normal connect-pnponline to the tenant-admin and then....

$sites = Get-PnPTenantSite

# If we need to target a subset of sites, do some filtering... "DTxxxxxxxxx" im my case...
 $targets = $sites | Where-Object { $_.Title.StartsWith("DT") }

foreach ($site in $targets) {
    Write-Host "Processing site: $($site.Url)" -ForegroundColor Cyan

    # Connect to the site
    Connect-PnPOnline -Url $site.Url -useweblogin # -interactive needed more clinking, weblogin seend to keep the sesh going so less clicking needed.

    # Get site web object
    $web = Get-PnPWeb -Includes RegionalSettings
    $regionalSettings = $web.RegionalSettings

    # Ensure RegionalSettings & TimeZones are loaded - Really need this...
    $context = Get-PnPContext
    $context.Load($regionalSettings)
    $context.Load($regionalSettings.TimeZone)
    $context.Load($regionalSettings.TimeZones) # Needed to get the correct object
    $context.ExecuteQuery()

    # Retrieve current settings
    $currentTimeZone = $regionalSettings.TimeZone.Id
    $currentLocale = $regionalSettings.LocaleId

    Write-Host "Current TimeZone: $currentTimeZone, Locale: $currentLocale" -ForegroundColor White

    # Check if update is needed
    if ($currentTimeZone -ne 2 -or $currentLocale -ne 2057) {
        Write-Host "Updating settings for: $($site.Url)" -ForegroundColor Yellow

        # Get the correct TimeZone object from available TimeZones
        $ukTimeZone = $regionalSettings.TimeZones | Where-Object { $_.Id -eq 2 }

        # Assign the correct TimeZone object and set LocaleId
        $regionalSettings.TimeZone = $ukTimeZone
        $regionalSettings.LocaleId = 2057
        
        # Apply changes
        $regionalSettings.Update()
        $web.Update()
        $context.ExecuteQuery()

        Write-Host "Updated to UK time zone and region" -ForegroundColor Green
    }
    else {
        Write-Host "Already set to UK, skipping." -ForegroundColor White
    }
}
