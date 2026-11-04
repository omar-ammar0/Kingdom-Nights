# kn-asset/1 mount importer wrapper (Phase 4.6). PowerShell, because this PC has no Python.
# Usage: powershell -File claude-tools\kn_import_mount.ps1 <mount.json> <out_dir>
# Writes <out_dir>\<id>_import.luau = kn_import_mount.luau with the JSON pasted in as a long string.
# The JSON is only parsed here to read its name and to refuse a long-string terminator; all
# contract checks run again inside Studio when the generated script is executed.
param([Parameter(Mandatory = $true)][string]$JsonPath, [Parameter(Mandatory = $true)][string]$OutDir)
$ErrorActionPreference = 'Stop'
$json = [IO.File]::ReadAllText((Resolve-Path $JsonPath))
if ($json.Contains(']==]')) { throw 'REFUSED: JSON contains the long-string terminator ]==]' }
$d = $json | ConvertFrom-Json
if ($d.format -ne 'kn-asset/1' -or $d.kind -ne 'mount') { throw "REFUSED: not a kn-asset/1 mount ($($d.kind))" }
if ($d.name -notmatch '^[a-z][a-z0-9_]*$') { throw "REFUSED: bad mount id '$($d.name)'" }
$template = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'kn_import_mount.luau'))
$lua = $template.Replace('__KN_JSON__', $json)
New-Item -ItemType Directory -Force $OutDir | Out-Null
$out = Join-Path $OutDir "$($d.name)_import.luau"
[IO.File]::WriteAllText($out, $lua)
"$($d.name) v$($d.version) (mount, $($d.parts.Count) parts) -> $out"
