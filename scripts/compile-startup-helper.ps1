$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'resources\startup\EdgeDropStartup.cs'
$out = Join-Path $root 'resources\startup\EdgeDropStartup.exe'
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$winrt = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\System.Runtime.WindowsRuntime.dll'
$runtime = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\System.Runtime.dll'
$winmd = 'C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.26100.0\Windows.winmd'

if (-not (Test-Path $winmd)) {
  $winmd = Get-ChildItem 'C:\Program Files (x86)\Windows Kits\10\UnionMetadata' -Filter Windows.winmd -Recurse |
    Select-Object -First 1 -ExpandProperty FullName
}

if (-not (Test-Path $csc)) { throw "csc.exe not found: $csc" }
if (-not (Test-Path $winrt)) { throw "System.Runtime.WindowsRuntime.dll not found: $winrt" }
if (-not (Test-Path $runtime)) { throw "System.Runtime.dll not found: $runtime" }
if (-not $winmd -or -not (Test-Path $winmd)) { throw 'Windows.winmd not found (install the Windows SDK)' }
if (-not (Test-Path $src)) { throw "missing $src" }

# NOTE: /target:exe (console) is REQUIRED, not winexe. Node's execFile captures
# stdout only from console-subsystem binaries. A winexe (GUI) helper returns
# empty stdout on most user PCs, so getStatus/enable always parse as null and
# launch-at-login appears broken on some devices but works on dev machines.
# The console never flashes: storeStartup.ts always launches with windowsHide:true.
& $csc /nologo /target:exe /platform:anycpu /optimize+ "/out:$out" "/r:$winrt" "/r:$runtime" "/r:$winmd" $src
if ($LASTEXITCODE -ne 0) { throw "csc failed with $LASTEXITCODE" }
Write-Output "compiled $out"
