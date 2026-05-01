$mcPath = "$env:APPDATA\.minecraft"
$installationsPath = "$mcPath\installations"

# Find Essential Fabric profile
$profilePath = Get-ChildItem -Path $installationsPath -Directory | Where-Object {
    $_.Name -like "*1.21.11*Fabric*Essential*"
} | Select-Object -First 1

if (-not $profilePath) {
    Write-Host "Essential Fabric profile not found."
    Write-Host "Launching Essential installer..."

    $essentialUrl = "https://essential.gg/downloads/Essential Installer.jar"
    $essentialPath = "$env:TEMP\EssentialInstaller.jar"

    Invoke-WebRequest -Uri $essentialUrl -OutFile $essentialPath
    Start-Process "java" -ArgumentList "-jar `"$essentialPath`""

    Write-Host "Install Fabric + Essential, then re-run this command."
    exit
}

$modsPath = "$($profilePath.FullName)\mods"

# Ensure mods folder exists
if (!(Test-Path $modsPath)) {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
}

Write-Host "Using mods folder:"
Write-Host $modsPath

Write-Host "Fetching mod list from GitHub (content branch)..."

$apiUrl = "https://api.github.com/repos/Shurby27/Servermods/contents/servermods?ref=content"

$files = Invoke-RestMethod -Uri $apiUrl

foreach ($file in $files) {
    if ($file.type -eq "file" -and $file.name -like "*.jar") {
        $output = "$modsPath\$($file.name)"
        Write-Host "Downloading $($file.name)..."
        Invoke-WebRequest -Uri $file.download_url -OutFile $output
    }
}

Write-Host ""
Write-Host "All mods installed to Essential profile!"
Write-Host "Launch Minecraft using Fabric + Essential."