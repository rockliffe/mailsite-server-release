# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"a833c51e0e32ff9c117f7834d910069c9080c4c2","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.com/api/installer/key","cacheId":"b356c23f0a7d703b293d8adf4c785e4b7b8a2f15af423e509260ad13c6316eb9"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='ndUucFmV16FElufV8Sr38i6RANKdd7E/dSHnGq/tyNFZYchknRPBCo9BK1HAIC4iiuQlCxhoOSZVN5q6zG99mDhGSPkr6wgXjwznzOHbpQw4hZ1hHCnjfLsWZv33dncoR8+Y+YxK8NE+PpAx4BCqB3Bn8As9JRoHFCPSUj9ZvrOdh8vmyjvnTeZ+H2j552ams3/tmR4KBx6qrlowcusJXWZJO4851rn/P9r9//qNKTlZx/En8Xx0g4NnwjLjTg+CCqZdxaadgG5OfjTo8CY4OSUatJ63A5yycCd6ye9UdMkuDG1jHk8j+BnXfFQmcxZi1QFPxlNHXqsq6BLQcO6DfDrw3boUdFx0k4oLYgb8JEWu/O2/f9CEqgrDLtJxWi7Bv1JHn9lIrt4ZzJ9bQwX8WuIry/Y1MdiZAEY09hNiMIeAPDctuMm3kV5Q8ZSnKvs+82/xSbG4vlL8VFldHLonJevjCaCj/t82WiwZ+/XS0eXpoxN3wpmYqdGrxTAapDKb'
$__miPublicKey='<RSAKeyValue><Modulus>sGV3KbkIpZN2KMR4MfuUqpizW+uqtbyk/TWp9lJykDlt3mvr2kyzkogcUAYkMu/7ghM4qwnbTj66LuDK0n82qLYW1F2N7n7/FNSeTt3KDf2/hr65CO8Nrgox+oSJFCO6Q6cgFmmf7bybtL6p75CEu5EYPsQBxOK/ycG/6u37y0ioq0Gq5XIf+T+5pFUNO+f4P/BuRgLpoXh8HMngcsN1iTDj1Y6lp8UBwZ+PStKSPNK3GPydVEU7MZQenRAYdbKXv+UdhFC6DFk/1oXZUb4E+YEU3hNB6XyNmQ5vEWy+xtpXkLYRSfCA+DsiGSGPYj72bp8FSRr/g6jfTV2FHEfCQeULQ+JQa8t/0FD+0fNb+nE/rMovo3KqcoIXYkgnFu3pPTJUbgclwxUg1fq8MlXsN8QfAmNBChyMs59XJl+ydTF7nzJcIxEvxP2X/FiKoLGgvq3hmAqnr7yzHqi7ftTx2K83KH2MPp6oo+y3Q1rmy3zry6LSc26VzG+KEzYFeEjF</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>'
$__miOfflineScript=''
$__miOfflineMetadata=''

function Get-MailSiteEnvelopeKey {
    param($Metadata, [switch]$OnlineOnly)
    $ErrorActionPreference = 'Stop'
    $cacheName = "$($Metadata.cacheId).key"
    $cachePath = Join-Path (Join-Path $env:ProgramData 'MailSite\InstallerKeys') $cacheName
    if ($Metadata.script -eq 'uninstall' -and -not $OnlineOnly -and (Test-Path -LiteralPath $cachePath)) {
        try {
            Add-Type -AssemblyName System.Security
            $bytes = [Security.Cryptography.ProtectedData]::Unprotect(
                [IO.File]::ReadAllBytes($cachePath), [Text.Encoding]::UTF8.GetBytes($cacheName),
                [Security.Cryptography.DataProtectionScope]::LocalMachine)
            if ($bytes.Length -eq 64) { return [Convert]::ToBase64String($bytes) }
        } catch { Write-Warning 'The offline uninstall key is unavailable; contacting MailSite.' }
    }
    try {
        $uri = [uri]$Metadata.endpoint
        if (-not $uri.IsAbsoluteUri -or $uri.Scheme -ne 'https') { throw 'HTTPS required.' }
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $body = @{ commit=$Metadata.commit; script=$Metadata.script; keyVersion=$Metadata.keyVersion } | ConvertTo-Json -Compress
        $response = Invoke-RestMethod -Uri $Metadata.endpoint -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 30 -MaximumRedirection 0
        if ($response.version -ne 1 -or $response.commit -cne $Metadata.commit -or
            $response.script -cne $Metadata.script -or $response.keyVersion -cne $Metadata.keyVersion -or
            $response.sourceSha256 -cne $Metadata.sourceSha256 -or
            [Convert]::FromBase64String($response.key).Length -ne 64) { throw 'Key response mismatch.' }
        return [string]$response.key
    } catch { throw 'Unable to obtain the MailSite installer key. Check your connection and try again. For offline removal, run the saved Install\uninstall-offline.ps1 with -InstallDir.' }
}

function Save-MailSiteOfflineUninstaller {
    param([string]$RootDirectory)
    $ErrorActionPreference = 'Stop'
    $metadata = $__miOfflineMetadata | ConvertFrom-Json
    $directory = Join-Path $env:ProgramData 'MailSite\InstallerKeys'
    # Reject redirected cache paths before an elevated write.
    foreach ($path in @((Join-Path $env:ProgramData 'MailSite'), $directory)) {
        if (Test-Path -LiteralPath $path) {
            if ((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Installer key cache must not be a link.' }
        } else { [void](New-Item -ItemType Directory -Path $path) }
    }
    $acl = [Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner([Security.Principal.SecurityIdentifier]::new('S-1-5-32-544'))
    foreach ($sid in @('S-1-5-18', 'S-1-5-32-544')) {
        $identity = [Security.Principal.SecurityIdentifier]::new($sid)
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))
    }
    Set-Acl -LiteralPath $directory -AclObject $acl
    $name = "$($metadata.cacheId).key"
    Add-Type -AssemblyName System.Security
    $protected = [Security.Cryptography.ProtectedData]::Protect(
        [Convert]::FromBase64String($__miOfflineKey), [Text.Encoding]::UTF8.GetBytes($name),
        [Security.Cryptography.DataProtectionScope]::LocalMachine)
    $keyPath = Join-Path $directory $name
    if ((Test-Path -LiteralPath $keyPath) -and ((Get-Item -LiteralPath $keyPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Installer key must not be a link.' }
    $temporary = Join-Path $directory ([guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllBytes($temporary, $protected)
        Move-Item -LiteralPath $temporary -Destination $keyPath -Force
    } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force } }
    $destination = Join-Path (Join-Path $RootDirectory 'Install') 'uninstall-offline.ps1'
    [IO.File]::WriteAllBytes($destination, [Convert]::FromBase64String($__miOfflineScript))
}

$__miBlock = & {
    $ErrorActionPreference = 'Stop'
    $bytes = [Convert]::FromBase64String($__miPayload)
    $rsa = [Security.Cryptography.RSACryptoServiceProvider]::new()
    $rsa.PersistKeyInCsp = $false
    try {
        $rsa.FromXmlString($__miPublicKey)
        if (-not $rsa.VerifyData($bytes, 'SHA256', [Convert]::FromBase64String($__miSignature))) { throw 'Installer signature verification failed.' }
    } finally { $rsa.Dispose() }
    $key = [Convert]::FromBase64String((Get-MailSiteEnvelopeKey $__miMetadata))
    $hmac = [Security.Cryptography.HMACSHA256]::new([byte[]]$key[32..63])
    $aes = [Security.Cryptography.Aes]::Create()
    $inputStream=$null; $gzip=$null; $outputStream=$null
    try {
        if ($bytes.Length -lt 64 -or [Convert]::ToBase64String($hmac.ComputeHash($bytes,32,$bytes.Length-32)) -cne [Convert]::ToBase64String($bytes[0..31])) { throw 'Installer integrity verification failed.' }
        $aes.Key=[byte[]]$key[0..31]; $aes.IV=[byte[]]$bytes[32..47]
        $aes.Mode='CBC'; $aes.Padding='PKCS7'
        $transform=$aes.CreateDecryptor()
        try { $packed=$transform.TransformFinalBlock($bytes,48,$bytes.Length-48) } finally { $transform.Dispose() }
        $inputStream=[IO.MemoryStream]::new($packed,$false)
        $gzip=[IO.Compression.GZipStream]::new($inputStream,[IO.Compression.CompressionMode]::Decompress)
        $outputStream=[IO.MemoryStream]::new(); $gzip.CopyTo($outputStream)
        $raw=$outputStream.ToArray()
        $sha=[Security.Cryptography.SHA256]::Create()
        try { $hash=([BitConverter]::ToString($sha.ComputeHash($raw))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
        if ($hash -cne $__miMetadata.sourceSha256) { throw 'Installer source verification failed.' }
        $source=[Text.UTF8Encoding]::new($false,$true).GetString($raw)
        $tokens=$null; $errors=$null
        $ast=[Management.Automation.Language.Parser]::ParseInput($source,$PSCommandPath,[ref]$tokens,[ref]$errors)
        if ($errors.Count) { throw 'Invalid decoded installer script.' }
        $ast.GetScriptBlock()
    } finally {
        if($gzip){$gzip.Dispose()}; if($inputStream){$inputStream.Dispose()}; if($outputStream){$outputStream.Dispose()}
        $aes.Dispose(); $hmac.Dispose(); [Array]::Clear($key,0,$key.Length)
    }
}
# Fetch removal material before the installer can mutate services or files.
if ($__miOfflineMetadata) { $__miOfflineKey = Get-MailSiteEnvelopeKey ($__miOfflineMetadata | ConvertFrom-Json) -OnlineOnly }
if ($MyInvocation.InvocationName -eq '.') { . $__miBlock @PSBoundParameters }
else { & $__miBlock @PSBoundParameters }
