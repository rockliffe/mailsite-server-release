# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"fa6a6ce5e924cae17e5043789fd0d7833e55e605","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"735498aa85e0da5cc1c8e935dd10bb402891509832863783758db39da874e1e6"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='GsGuM4g22qpqqDiL+fYKHqzYtqm9e1PZKtLlF9UQVOANDbHVP/aUpxLdZ2MIFTI4YyLe7BSg/W3afZy8pwpF/eb8xMo0V+KQq9s56B2zKb93TWPVeBZu3Jlu3k5sRGf6+aJuKpI1Ps5fTcjTufzY6Nv941VxdoBPfVuQoQF+Acg3ZtV5Iyo5oVyyE372kzbJQAjZUW2PLrEbOgPBUcjsA2ieIeH3WJmfDo15T+MkxE138VXL2pXTpwB7wp/8Yf6dFnbVlBaMDVX5zGIvpex4tbTX8NOgVV8lGAkAHo7ubQp1Q6MD75A/3vP59Dfo86+C+dxAZ7NaMzKCv/USJuJ5Cut5VY1eEafm4kdeZHAbhXXTBHCW5IA8Hl8SHvA6XLcog7KLwU5fJMrjvr7SVeMkE9m6alJXwaZBkoB4nGy5cxLg7yMcTYmV500ptg0f4EGwxIBRBe3lqAUMbLt8VvzwObugMULJiKcovJIxlEaQcCAt4O5coKjBWKoH5Kqi8ZLf'
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
