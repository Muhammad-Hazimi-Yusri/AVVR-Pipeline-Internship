invoke-expression 'cmd /c start powershell -Command { .\triggerinteractive.ps1}'
sleep 10
Start-Process powershell "-File .\dockercopy.ps1" -Wait
Start-Process powershell "-File .\executemonodepth.ps1" -Wait
Start-Process powershell "-File .\extractDepthMap.ps1" -Wait
Start-Process powershell "-File .\stopDockerContainer.ps1" -Wait