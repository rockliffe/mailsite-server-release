# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"afd45b177509726481b22b5b0bd9a9b1180ba425","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.com/api/installer/key","cacheId":"90b2d4b9ae6723ec237fc3bc10dabd3d6af9654f8da992589702a1f1db88b869"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='kUBkfW4qvTbfB5WHNvfz6l/5MBEO6LxJbyxuywrtNT/MoSZLrkLJRQWLiRysYfEDMxnIZwRnd9okbtYBKAjryvlzIVhksxmJXHuMLBz0ahbEipHe3lcmgaUd2AqomUcDFnLKxdB2KjKxDLqDfcMEIfibSy6hOUUCv2EyM8F0j3moBcdIXIHa143Q7WFfq5B7kJ+87kLh9hcTukpeCgwlxwgTUwR4g8pTIsShga3+w+3zL2hJ1CMdDK2+8eqoviWDWTzJGRGkN9sKPbpxu7+3MzETY2u8cOqJU6fw5XbnjgIqfElvO03fPf5xxQ9VNXTt3Zfr2VWnyIxWTQtxyALpktn874ao++Q0Y7JOiO7W9MO0iIC/RIOtwl8e85dbaNkSD87iK76dWJsJyC7fbCIW7FzhHg2iwmGtED+o29B21KsqiSTn5b2uWta560DdDJAwDyWQb2l0iKRFTMOCkJB82FVbuuSfhDTfnRwQPQLTLRLhS0TF1PyOiyDlLIsQOsab'
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
