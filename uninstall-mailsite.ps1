# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"0d5d3a18dd3bbb488e7253319133c934681b1743","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"80c8a9661e35903b1b4667495e80c18d582cd842961a1a326e39f57bd1a1f36c"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='lQgfeZZLh5H7hlOM+wwQmEf/k5N/4JtlOxmM5Y7vDH+IXkfGuPDbFCPl2SUNDtxQFf7B+P+tduZxqWrHKjBSS1HF709ZxgnD2ogaxUY1wFVQkxGEl90llVoASyIFFV6nzPSLMdS3JnQyC9eOQEGr8ES7qSNTzlAV/mqY4WzofyAmMl8qyZKA7o4KGlIAxF8Ng7TWlG3wwsaDAnmUQ8DCsGhPRP3Qob50HnTqOKLiYsA5TcQn+fV9GQKA85ghWULrLzm2ygyrsRGpEiWjRYUEzkHgQACvnljVMefNqwCWMF0GFZh5V6aJQekj8kBgDs4GqUJkhFkKYqfrC4pS0uQi8C6z7Lt90d91e8a4VdwvFt4h7HmAVL7h9uuKSbTqsIk3p9rfndy9WLaDeyAqCZebDAliy+x3K1bJxxrV1VXTLqZFwH3eNHKj8Y5BjrBNXzgOZzyeFZw+VKXdCHw2+Nilyh7Qc9uZCAx8VfbWMfQup8ZuIYoVT39j5Su/daj/fxmC'
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
