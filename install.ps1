$mcPath = "$env:APPDATA\.minecraft"
$installationsPath = "$mcPath\installations"

# Find Essential Fabric profile
$profilePath = Get-ChildItem -Path $installationsPath -Directory | Where-Object {
    $_.Name -like "*Fabric*Essential*"
} | Select-Object -First 1

if (-not $profilePath) {
    Write-Host "Essential Fabric profile not found."
    Write-Host "Opening Essential website (manual install required)..."

    Start-Process "https://essential.gg/download"

    Write-Host ""
    Write-Host "Install Fabric + Essential, then re-run this script."
    exit
}

$modsPath = "$($profilePath.FullName)\mods"

if (!(Test-Path $modsPath)) {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
}

Write-Host "Using mods folder:"
Write-Host $modsPath

# GitHub content branch folder
$apiUrl = "https://api.github.com/repos/Shurby27/Servermods/contents/servermods?ref=content"

try {
    $files = Invoke-RestMethod -Uri $apiUrl
} catch {
    Write-Host "ERROR: Cannot fetch mods from GitHub."
    Write-Host "Check repo path or branch name."
    exit
}

foreach ($file in $files) {
    if ($file.name -like "*.jar") {
        $output = "$modsPath\$($file.name)"
        Write-Host "Downloading $($file.name)..."
        Invoke-WebRequest -Uri $file.download_url -OutFile $output
    }
}

Write-Host ""
Write-Host "DONE! Launch Fabric + Essential profile."