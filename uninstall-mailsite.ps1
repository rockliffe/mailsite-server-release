# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"de663e60e052c312c684b8a64a44513e3ca4f1bc","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"e5511477ee87e01157ccada3a124eb411e789228ad398d82143b1a4c6d6e2da3"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='SNDD2TGNQ4O43xEGhWWfJHE1IQ07GlGe0hpU83zxs/ep0ovJhwF232E5Ve68iCvi+BPLrHOGy4aUt0UvnXR0lpba5VaYZlREa8HhYJWlknSatS6TJJDArKYTxr9JnJIPQkv6wCvSplZ0q8osrNnqXt+jY5TLdLzvRu/n8eR90T9GAzOnsW2mj8V28bVcmk2MjFCwQDd8vxQCmRNkC73NANcGG7Uj1bawk2lWatGYgTPcYl7w6iRLvVvOH4NSjZ7C/TrO+jYbaoy/5APb4swQU5vNEgbT+JWxjiBpG6q8IWg16nRonZklkOJYur0n9ak79snT6ZxnoypQ5m7hGz1GCHzWofuBW1niyuugYlXEnw7oiT3YRCtcRjHoZUVSdtnbonks+VrOs6DILLVLKvj0PsCbGb56dk25nLsx/OQ+iwln4GztUjGQLmXo5ezQWfLa5/kRMbIpmxCCJDsyGCIQ7GpQwkCsGF/G+jUTZn2Ed0j1leZ6SE2nJo/lAOr++BQ1'
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
