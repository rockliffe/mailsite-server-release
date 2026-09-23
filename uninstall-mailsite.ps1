# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"2405664d67383e770cf0d705f013ef8339c2496c","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"2d14249cdfced40daa63cc112699b3552b2f65773fc740187f85371fcc711b89"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='PosGxIbmG5UQnj1gApch8AU1qg5BskBBkyc6xzRrzIpfGszqllJuigB5SkiAHJM74tNZBDW/AYbfAG6A4G/ngMPn+gHrHkx7IntAVaxWYyrl6f7+rHSw5IP/j0lJb1rnz94VkhBPS6KYo9stvwEfvrhSbVBWaZQoNYNJCuxVtd+l8JNIU9ZU6ki2suGhH+wvM+c2UPHaft6+Pdle475VlH6aLRKxaK6+vRQInnR1VkwG8KQotn6rRo9OlHVzb2qcCOrTCQPUzyLYL77/KJreIBTgp4Bv9Kl7B7ZCi7Va5FUthHr++wmvnUtGSBRGWxp7XtHrtZ+RC67rmwXKXh4vyQMzUKNG3njhAu/7knrXRGeEPFj60gK+lfgYEr26CArck5CbYfGbeG7a3/JlT4iwS3lbHAnx6Oj8rN/aGZPbOPaFwI2o8iep0IEMsYof6lkIidUMUBy98tCojPCeXwVoVPlG2UOgwfchgC0IEYoA7KS2sVJSVsCIW3+4mLyBnqBz'
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
