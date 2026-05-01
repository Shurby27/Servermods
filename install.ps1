$mcPath = "$env:APPDATA\.minecraft"
$installationsPath = "$mcPath\installations"

# Try to find the Essential Fabric profile folder
$profilePath = Get-ChildItem -Path $installationsPath -Directory | Where-Object {
    $_.Name -like "*Fabric*Essential*"
} | Select-Object -First 1

if (-not $profilePath) {
    Write-Host "Could not find Essential Fabric profile."
    Write-Host "Opening Essential installer..."

    $essentialUrl = "https://essential.gg/downloads/Essential Installer.jar"
    $essentialPath = "$env:TEMP\EssentialInstaller.jar"

    Invoke-WebRequest -Uri $essentialUrl -OutFile $essentialPath
    Start-Process "java" -ArgumentList "-jar `"$essentialPath`""

    Write-Host "Please install Fabric + Essential, then re-run this script."
    exit
}

$modsPath = "$($profilePath.FullName)\mods"

# Create mods folder if missing
if (!(Test-Path $modsPath)) {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
}

Write-Host "Using mods folder:"
Write-Host $modsPath

Write-Host "Downloading mods..."

$repo = "https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/contents/mods"
$files = Invoke-RestMethod -Uri $repo

foreach ($file in $files) {
    if ($file.name -like "*.jar") {
        $output = "$modsPath\$($file.name)"
        Invoke-WebRequest -Uri $file.download_url -OutFile $output
        Write-Host "Installed $($file.name)"
    }
}

Write-Host ""
Write-Host "DONE!"
Write-Host "Launch the Essential Fabric profile in Minecraft."