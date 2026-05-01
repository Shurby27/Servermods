$mcPath = "$env:APPDATA\.minecraft"
$installationsPath = "$mcPath\installations"

# Essential Installer Downloader + Launcher

$Url = "https://cdn.essential.gg/installer/3.2.4/essential-installer-3.2.4.exe"
$Output = "$env:TEMP\essential-installer-3.2.4.exe"

Write-Host "Downloading Essential installer..."
Invoke-WebRequest -Uri $Url -OutFile $Output

Write-Host "Launching Essential installer..."

$process = Start-Process -FilePath $Output -PassThru
$process.WaitForExit()

Write-Host "Essential installer closed. Continuing script..."

# FIX: define mods folder correctly
$modsPath = "$mcPath\installations\1.21.11 Fabric Essential\mods"

if (!(Test-Path $modsPath)) {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
}

Write-Host "Using mods folder:"
Write-Host $modsPath

# ================================
# GitHub DOWNLOAD ALL FILES (ROOT OF content BRANCH)
# ================================

$repo = "Shurby27/Servermods"
$branch = "content"

# IMPORTANT: root directory listing (NOT /servermods subfolder)
$apiUrl = "https://api.github.com/repos/$repo/contents?ref=$branch"

$headers = @{ "User-Agent" = "PowerShell" }

try {
    $files = Invoke-RestMethod -Uri $apiUrl -Headers $headers
} catch {
    Write-Host "ERROR: Cannot fetch mods from GitHub."
    Write-Host $_
    exit
}

foreach ($file in $files) {
    if ($file.type -eq "file") {

        # optional filter if you only want jars:
        if ($file.name -like "*.jar") {

            $output = Join-Path $modsPath $file.name

            Write-Host "Downloading $($file.name)..."

            Invoke-WebRequest -Uri $file.download_url -OutFile $output
        }
    }
}

Write-Host ""
Write-Host "DONE! Launch Fabric + Essential profile."