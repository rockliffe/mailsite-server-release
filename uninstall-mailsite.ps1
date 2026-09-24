# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"d316cfbb58088cb8778bdd5eb5eae61d443d9737","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"af4a14d8f62d3ca281954208ac1c5b6b828bee7335bf7ac9fc187675999d5cd4"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='HlTDr8mpBpSOzCLWLdCLRU8mTAV+sUZWsy2Dc2RqIy0kELr/frLdtMM9Ah+dWOufPMIo6Oa0hlOtKlEauCdFQ9/mqLdha9xFk1EED9jGQW+XRX8ESqXVjaorVRYgYOy2vNR4Uy7DGCUDtVxzcoMnKV7xFXU6AND3HQKISPjV6jPqSYFyEnv2CnkNMsB4mNOMVN75P59a2iUUzXGTcBHWnVGKyJKLwXEI1F/UBoQ+ZCGhfnkof/J0VeejvEsL3XpNPTlEp3uniyb2Qwi+ANE2Q24iroPyCmI24qdOrSGnmYsKd6zkoHUwfkysZ0pPZLMgH9NupJzTR+yY/IL3gD9cQhnhmr1XUQeKNeU408E6EJEdeKEXM9flDHcLATvFj0tYCYm+RU+vBBZukR5vrL96DpRRGjtiSya8xxIOs+rGaKh1UYRf6DvcQCEaqtYdoarKW4gd/898yYy7f2NNneMfAhXDnqJqUZIr/UV118J/7B36kDP3HqGvTPOpXsMNIyz7'
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
