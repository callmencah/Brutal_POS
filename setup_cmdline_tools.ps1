# Download and install Android SDK cmdline-tools
$sdkRoot = "$env:LOCALAPPDATA\Android\sdk"
$zipUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipFile = "$env:TEMP\cmdline-tools.zip"
$extractDir = "$env:TEMP\cmdline-tools-extract"

Write-Host "Step 1: Downloading cmdline-tools..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
Write-Host "Downloaded. Size: $((Get-Item $zipFile).Length) bytes"

Write-Host "Step 2: Extracting..."
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

Write-Host "Step 3: Installing to SDK..."
$targetDir = "$sdkRoot\cmdline-tools\latest"
if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force }
New-Item -ItemType Directory -Path "$sdkRoot\cmdline-tools" -Force | Out-Null
Move-Item -Path "$extractDir\cmdline-tools" -Destination $targetDir -Force

Write-Host "Step 4: Cleanup..."
Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done! cmdline-tools installed at: $targetDir"
Get-ChildItem $targetDir -Name
