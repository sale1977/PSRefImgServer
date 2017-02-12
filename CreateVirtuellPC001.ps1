# Set-ExecutionPolicy unrestricted

#Check if VM exists
$VMName = "PC001"
$VMLocation = "R:\VM"
$ISOFile = "C:\Users\sale\Desktop\Windows2016.iso"

if (!(Test-Path -Path $VMLocation)) {
    New-Item -path $VMLocation -ItemType Directory  }
 else{ Remove-Item -Path $VMLocation -Recurse -force }

$VMexist = Get-VM -Name $VMName -ErrorAction SilentlyContinue


If($VMexist.Name -like $VMName){
    Write-Host “Removing $VMName” -ForegroundColor DarkRed -BackgroundColor White
    $VMToRemove = Get-VM -Name $VMName
    $FolderPath = $VMToRemove.path 
if($VMToRemove.state -like “Running”){Stop-VM $VMToRemove -Force}
    $VMToRemove | Remove-VM -Force
    $FolderPath | Remove-Item -Force -Recurse
}


New-VM -Name $VMName -Generation 2 -SwitchName intern -NewVHDPath "$VMLocation\$VMName.vhdx" -NewVHDSizeBytes 40GB | Set-VM -StaticMemory -MemoryStartupBytes 2048MB -ProcessorCount 2 -AutomaticStartAction Nothing

Add-VMDvdDrive -VMName $VMName -Path $ISOFile

$dvd_drive = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd_drive

vmconnect.exe localhost $VMName

Start-VM -Name $VMName -Passthru

$VM = Get-VM -Name $VMName
while ($VM.State -ne "off")
{ 
    write-host "The VM $VMName is still running ..." -ForegroundColor Green
    sleep 20 
}
 
Remove-VM -Name $VMName -Force
Remove-Item -Recurse -Force $VMLocation
