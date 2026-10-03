# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"e4f2caca9e93e8f6b38aee00709c8039cfc9f876","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"3cb4ed721483327ca84f9f1953d9804c00d2e4c21c4573ce861dd699e970ed45"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='Lq1q5uvJGGvPYuRXYVzzE8549On8ipZBqkLVz6HQ+Da5CAaGZBRlCuETcvi63bciCUfQCMLCca1AwWJKejJeufLmf8crnWeMUj0N+kmTmMCND2YnJxiXLmrQOsdxiohXcp9WdFKSQLWFzW3vVKY6QIYxfWDDa8QrysDwMGJynwv1jOr2QS0tU6bs14V5ciZcRJMDFl+Unr3K/5vQv/hVPKu4PaFKgvBqkzkhGO4XQAX4Z2Rfq65b1UdcztHeWv/QTdxDKVWsTDG5CZ+wMKU0ooKkNzp7deUXjAmbR5dB0lLnxyNwv1LlgI9y8P3O9qTbA51edKEwpwj0EDv9jB6FlfG9CIhuWW1dwOWWJW7D/GX/00HWcamD7P/t7a6D6or4h5x6QHeUTM1vebfEWzAqfJKiUgmgvIkSM2vEDPLJWackd3kODyZ3btVNWEYNl3ZDbbP3laMpsYXaReqbxwWpxEehe4f5Iq5fhFT+ZV5+qgAKsapS3nNxl+tCpFN3ZGMT'
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
