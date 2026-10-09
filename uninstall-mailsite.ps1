# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"1f7af37156ba4b5366d8702e8a686fa0a550c3e7","script":"uninstall","keyVersion":"v1","sourceSha256":"7687998679849203924ad28d279d573daa1f606f0f7597c7ab1a7b74b53a2aae","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"94e104e92b209488052e017e6cb7cdf6b3274c7e0a2beff0f176e8da729acca9"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='WrfhkRKlrbK/Nc9x8COwl47Tert0dqpu8l/IWgsGYLdljCEyTitvzTOf1YKJT2ikuvh/UpbznsrlFgTZZsg1ZuCEZZ8oew5tjRyKzf2msRDU/SrqB4IqYirT4wVjo9P0+nH8/j4VAZz2SHDzMXXb6dd58P6ftZW7wtgC1+Lby1c0Q1zNFr0Z8b59L6SNYjOM0nd0Vq+RplS4btvX6Ao4lhSFrNaJAAiT11HePgxrC61pVFK0Aw6G7eOT0WImPtgLXCWiXF0Fqlghy8n8fE5lK0IzZ24aGZBtoJ3kCtf9IhhkmexZFBYon5Haow/ugpFAjDFxBysWDiVuuJUiWswN78a4Gc7kHhr9fNHT1qiMQCyAa7VqBcNDZ66bXD7i0ouVFD/vKubgcyP2mUU+lAoAX0Sl6bcRw0R6WWVjpWZupkgW2jLqj3Im+UkcVaEsERaRNFByXbnPpPK6SuSOUR2Er9tgVLT7RiSu8ynZ2Wq4PvM84cHudq4ithAXg1XPkBjO'
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
