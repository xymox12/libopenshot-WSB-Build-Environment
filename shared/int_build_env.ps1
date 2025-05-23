# Change working directory to shared folder
Set-Location "C:\shared"
# Winget
$currentScriptPath = $PSScriptRoot
Write-Host "Current Script Path: $currentScriptPath"


# $progressPreference = 'silentlyContinue'
# Write-Host "Installing WinGet PowerShell module from PSGallery..."
# Install-PackageProvider -Name NuGet -Force | Out-Null
# Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
# Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
# Repair-WinGetPackageManager
# Write-Host "Done."


Start-Process -FilePath ".\msys2-x86_64-20250221.exe" -ArgumentList "--silent" -Wait

# Install Python
#Write-Host "Installing Python..."
#Start-Process "C:\shared\python-3.12.10-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Install Git
Write-Host "Installing Git..."
Start-Process "C:\shared\Git-2.49.0-64-bit.exe" -ArgumentList "/VERYSILENT" -Wait

# Install CMake
#Write-Host "Installing CMake..."
#Start-Process "msiexec.exe" -ArgumentList "/i", "C:\shared\cmake-4.0.2-windows-x86_64.msi", "/quiet", "/norestart" -Wait

# Install Visual Studio Build Tools
#Write-Host "Installing Visual Studio Build Tools (this may take a while)..."
#Start-Process "C:\shared\vs_BuildTools.exe" -ArgumentList "--quiet --wait --norestart --nocache --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" -Wait
# Install Visual Studio Build Tools C++ workload from offline cache
#Start-Process -FilePath "C:\shared\VSBuildToolsOffline\vs_BuildTools.exe" `
#    -ArgumentList "--noweb --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --quiet --wait --norestart --noUpdateInstaller" `
#    -Wait

#Start-Process powershell -ArgumentList '-NoExit -File C:\shared\build_after_vs_install.ps1'

& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "https://github.com/OpenShot/libopenshot/wiki/Windows-Build-Instructions"


$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Setup the bash environment
& "C:\msys64\usr\bin\bash.exe" -l -i -c 'cd ~; echo "PATH=$PATH:/c/msys64/mingw64/bin:/c/msys64/mingw64/lib" >> .bashrc; source .bashrc'

& "C:\msys64\usr\bin\bash.exe" -l -i