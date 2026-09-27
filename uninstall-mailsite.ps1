# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"cc4eca1f7dde4362adbc3eba3471f624fc74afc4","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"e440631f2df2a04392928756dbcb407c76817651d116f05a380b2981cd2ed059"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='q2dYqoq+9TcSQdrHkoAa7ITfrtoOnHugEWKQ0btVdJDdKMzF7URZWvbTWriMPDZFEq7AhDDHJkh4UBPEovFkqONI5xGJl0at6JC4SQJhcpGCO25aM+wcPPP+aEU3XeGNQt2X5nVhf+1i+kLOZFrTYmJM4HqCOAoJvf7xPwTKixcuVHern7dNxUv/ye2yBwWESiVZRI0NnKr1C/gY+n8g3T/HoM5TZyNVUXMhFzuC5pB/uskE8CgX8L2WjpGHXlmjDpuocktG46lwkS/SdkroLMZB4dUC2ZALGoumJogq9Wrz7bCYiYUJIEeJN/44aHNfi+Oy8mYXr49AykjJbepOwB9azNmRgR9SWRqN0qkPggLsMaJbXDj7l/p7zm+YHqxXuR7xDE7RN5jQJGzQruTQUG8fRw8q2r+RH5p+uiO2LgqenRk4R2a7yxE1ITVPwdHZicS9US7CbX67YZh91Zz/d5pb7+tIQK7m657OAK1spONVURgOlXvlg58u5WcfSq9A'
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
