# Install cmdline-tools from downloaded zip
$sdkRoot = "$env:LOCALAPPDATA\Android\sdk"
$zipFile = "$env:TEMP\cmdtools.zip"
$extractDir = "$env:TEMP\cmdtools-extract"

Write-Host "Zip size: $((Get-Item $zipFile).Length) bytes"

Write-Host "Step 1: Extracting..."
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

Write-Host "Extracted contents:"
Get-ChildItem $extractDir -Recurse -Depth 1 -Name

Write-Host "Step 2: Finding correct folder..."
$sourceDir = Get-ChildItem $extractDir -Directory | Select-Object -First 1
Write-Host "Source folder: $($sourceDir.FullName)"

Write-Host "Step 3: Installing to SDK..."
$targetDir = "$sdkRoot\cmdline-tools\latest"
if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force }
New-Item -ItemType Directory -Path "$sdkRoot\cmdline-tools" -Force | Out-Null
Copy-Item -Path $sourceDir.FullName -Destination $targetDir -Recurse -Force

Write-Host "Step 4: Verify..."
Get-ChildItem $targetDir -Name

Write-Host "DONE!"
