# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"00160e0260a6502db43c3b08db590e747ec29c04","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.com/api/installer/key","cacheId":"bd0695f392dfb7b9ddfca34dec4d1855b8897ac97a7db5eae856799872aadbe0"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='ScJu3yEhmT2cWArlceUExwRqkt+fvk15pGKQUaQhDpQT52DaYB2FB++Tq3kIoOdcUuE8F/KHX313gpOghp05QZCxhjA1pfehyLiyE5iy16Kxbq995R7FyqggAsX1j1DxcnFEnMtYCzwVCkfD2dT8LZvdY2RJ2dohdEdgZCHAZyy8gAIA31TyebJ9dGceob7kws5Neidw+mba0AnznudKfSq9uqpaIw1m7G+j8G9ylaGacgzjdQnP+DuYp9khAB0zXzr/pX9xAuncdJ+/oKt/GstkrghqAFNrsAbbFztD2ihmOpjiMk8DRsOrBIa7MOyTgaBlolAQO9IbfyGmT0qQ3EgOlfpu/D8qGdlC4NYPf6fBtc4tVetoqp6q9lMkyCIGUPNfk/8umnmBtNfZSgclpURjPewNK+INdLY7CpDwd9nUrbpGVt1JWdSG5aFwER7OW6de07wUwZtEhcmcpu73MIlzj+GmevycB9xmKYn+pAp3R78IWHKW4nYA8RUK95gv'
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
