# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"ea627c83d5c0caaa0a512ede442024b8d2fead38","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"cdbc0cd179ebdeb5e12ecd27463eed13338f229a89971e98cfff9a8336867df1"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='f399Oim5qbhNGpqnbfvvrGUlFcO7ArcQpefhhBVIT1jGKwA60sohZZ+yuQwH7613NXwINlTGpWW1lb/1kl2Wmkz/YJZxQoy6345+pvVh/yLFXvHdA3fQSyO6pHZnyvOr+QxxEqUHiuOVhbVBw35SpjsjLaKp48RwRqsFxTxXK80RAyQbe/KP50NQaKpIhhAsasfwI+cJUl06juyGJh1nwY4S1xbfIjbkp0epnjL387w29hFhxMigRxrZC6lgEFUDWYVSt+rkoHDWqP36hR30naaXwjbr7L27IK7TXvwrBvO4vIK/LfkWthhiAE40QT2Lx+VWe7RleojGaJt9QcEHQzN8dDLNYLThgWHvrhSG2kZLXtxBDmXtXwU5y/5m55BTtQx1MAESRsV9j3aqizpohhWG+RRZjsVfGHSFLcD3SM27+ZC9H3WZ/nhNCmHXCRf5Snw81UnAkKYXzDr2TXT4vNb3HGthGZjtzaHsshZdz5uAkDZRCcBrsNeKy/RmFz5/'
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
