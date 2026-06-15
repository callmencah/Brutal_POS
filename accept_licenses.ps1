# Manually accept all Android SDK licenses by writing hash files
$licensesDir = "$env:LOCALAPPDATA\Android\sdk\licenses"
New-Item -ItemType Directory -Path $licensesDir -Force | Out-Null

# Standard license hashes that cover all SDK components
$licenses = @{
    "android-sdk-license" = "`n24333f8a63b6825ea9c5514f83c2829b004d1fee`n84831b9409646a918e30573bab4c9c91346d8abd`nd56f5187479451eabf01fb78af6dfcb131a6481e"
    "android-sdk-preview-license" = "`n84831b9409646a918e30573bab4c9c91346d8abd"
    "android-googletv-license" = "`n601085b94cd77f0b54ff86406957099ebe79c4d6"
    "android-sdk-arm-dbt-license" = "`n859f317696f67ef3d7f30a50a5560e7834b43903"
    "google-gdk-license" = "`n33b6a2b64607f11b759f320ef9dff4ae5c47d97a"
    "intel-android-extra-license" = "`nd975f751698a77b662f1254ddbeed3901e976f5a"
    "mips-android-sysimage-license" = "`ne9acab5b5fbb560a72cfaecber8acf4457f3ed00"
}

foreach ($key in $licenses.Keys) {
    $filePath = Join-Path $licensesDir $key
    Set-Content -Path $filePath -Value $licenses[$key] -NoNewline
    Write-Host "Written: $key"
}

Write-Host ""
Write-Host "All licenses accepted!"
Get-ChildItem $licensesDir -Name
