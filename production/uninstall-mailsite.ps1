# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"d8c0541151b82a7b447e2aa9aab77a31652db389","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.com/api/installer/key","cacheId":"afb2a06c5a280b54d04da41b52a776dff0131a95f2ada4cd6fd464fb5f0dad48"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='M9IkyZAgMG0uEJ3MvI/Sj6roT14m1n05d6XjamqW2827AgAbVy+LrU/QtKkkqxtvzFmevRwpYMDWRqaO02bQMo4fzh0Qcp71XqiXU/5nVwVVxTYbFOfpWShtaGnmV4mPWmhjmS46p2rUip9EkKmL3a6ytc9e6gyFgMIaWUxl2DdIqMzPGoSsWMvHSgNBLZVBM/A2GYsNJbSLMMo8VCSL3K9tIj2CH5MU8tTFPmmBQgliiA74EVcKcuuhXGYl/qtOnhRwWM0spxRwgMQN1aWPjDue3IHY6hDsQlz91Rh/49PrxolxPUw6xHaa/XrtdcfsBocUIPG+3rddI7u2CLUseIjSEJEpvcHOMu7zOIk3lRtGrULS4ZEMle+awRhgiVJoA8Q1U12AMmElxPv0bTgqwF/F8oYJN/R17Hrn6ZMVFP2kwKWqWMph8Igmr24Qe6Xxdh0NZggsss7LnyuYJQMTaJaLpDM7Ta6MbnDNLVNO7WKtk5kUP2JcPHAro/20/cN/'
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
