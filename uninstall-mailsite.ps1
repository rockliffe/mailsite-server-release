# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"f55b516dfbdfbe2333468b8b8e823cef5019cb5a","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"fa87bcf22e997581705511d3b8e092924f92890aa62845005362cf3f358d2956"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='FjBQhVaj4F7AcWHqkKAcrAphGOgqk33qqMKCpICDEuZ6BTidaPhnHsanFy7b0qu8gm67Ifd2N5+FyPU/v6Zc0pNnN/rPcX1JUVTN46whHl5gobAgOu0b9kS8SRBL5zAlIx4JOOMWa4HJ7CYv37LolqdCUiTCGHqGfz+AzGy5PhsSa1zrfDMZobvjhpzBELHG/8POfHWwVVD6ou1dDRns5hJYXKRu0ypC3i3dAVlVcw9XnG3lDXeBYq1vB8wV2cN/YcDHi5qKj5hzzIaP74dYssE+SIoEInR5NnHKp5UyI3VvWaF23EZVsc0wkq5NUWsJyCTAG/wqJKdBRcgOpHF2QiGipwX9Jz4fYQgyf0z6t8aTXCmEGhpJ7tO0fQn/Geb/ZrjLjBvPr7yLsBfy4OMjmIPux+Hu8DS7kXWDi1K3L5x4tZcCEIlindtEbd05UYdICcJnYZtiuNpVy5AW1WEn/x+0TQlWOjNuQ/b0ZvGhJvd8aNe3xoYNl78qsmPLGJz3'
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
