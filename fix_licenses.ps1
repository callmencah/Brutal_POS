# Fix licenses with correct hashes
$licensesDir = "$env:LOCALAPPDATA\Android\sdk\licenses"

# Remove old files and rewrite with correct format
Remove-Item "$licensesDir\*" -Force -ErrorAction SilentlyContinue

# The main android-sdk-license needs these exact hashes
Set-Content -Path "$licensesDir\android-sdk-license" -Value "`n24333f8a63b6825ea9c5514f83c2829b004d1fee`nd56f5187479451eabf01fb78af6dfcb131a6481e`n84831b9409646a918e30573bab4c9c91346d8abd"
Set-Content -Path "$licensesDir\android-sdk-preview-license" -Value "`n84831b9409646a918e30573bab4c9c91346d8abd"
Set-Content -Path "$licensesDir\android-googletv-license" -Value "`n601085b94cd77f0b54ff86406957099ebe79c4d6"
Set-Content -Path "$licensesDir\android-sdk-arm-dbt-license" -Value "`n859f317696f67ef3d7f30a50a5560e7834b43903"
Set-Content -Path "$licensesDir\google-gdk-license" -Value "`n33b6a2b64607f11b759f320ef9dff4ae5c47d97a"
Set-Content -Path "$licensesDir\intel-android-extra-license" -Value "`nd975f751698a77b662f1254ddbeed3901e976f5a"

Write-Host "License files written."
Write-Host "Now running flutter doctor --android-licenses check..."

# Verify
flutter doctor --android-licenses 2>&1 | Select-String -Pattern "accepted|not accepted|All SDK"
