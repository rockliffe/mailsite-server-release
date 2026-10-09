# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"1f7af37156ba4b5366d8702e8a686fa0a550c3e7","script":"uninstall","keyVersion":"v1","sourceSha256":"7687998679849203924ad28d279d573daa1f606f0f7597c7ab1a7b74b53a2aae","endpoint":"https://mailsite.com/api/installer/key","cacheId":"ae27f6e4fe4a6e2fd088f53e602ff3c467293306a0e0257995955faace75f072"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='VrrIU53xcSxyugM8zjM4O1jbQMrqn0ivKQwQ5qEJqWD84unPOpiwuzdGlGl82NETIa7fQ4aLR90+NtYqtHU7v608PxrasbJDXkyjeptzsvynJ+fwfXdU7/hp6QD+WlMN1WLwimwxlZ2WlZ4dZTvjmNwiLoNbLvr9eVa5ynZTuZIkdJ7Xc5kA5RSrEZ5dPXE47sz3CiU9Vgk9nVrRsEnH8Qv+euD4aZcM26bAM2ZTwKq5hjUOPoJZQ2rwKZRJiGptxrSZycfyaTQAijRXoR3QtUuQ55lDXI6SXmUl4eKCwyTy1mgWagTeKSWmpMyS4RYP63TpcUJDTCQjH+MuvNZQgkXXR1x9gYoiTjtS8H2CSjEnmZQySwW7CJtsSY0x7/2O+2TRuEsJUMOKQ2dRDalfgGdbMLJMzTtGfZbSF2WYI1PWHoLqPQmRMGt0ZWDQOCdKpSSQyVLLwtKP0rJWh04BkV2BD6fgOyuLGLx6tUv4raLtb/KCcbfIxHYv5YXl7swi'
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
