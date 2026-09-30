# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"1e93d735e098de2afe0badf53c86687264a8d46f","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"e36ed52d061d8302908dab7018e2cbef914250fc916f30cd0a68c6c980ffaa42"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='cdfI6qUi+RD2zAE9aMULdgjPJJPPHuV+wR7EnBPy7QmpswppnX0bKw6V08ymnLFYX5PVyyoeQn+uiiQOqtyz7KtCoexfqMUrFlvfxxlhHCHMQJIETYH4TN4JJtkSKvVQ61RckhKjBknPR5zAzcHJ93KxrX9QhbJJssv3Dee/8s0P+t8kW3Q+DoIGJMJQlwG7Rw9NQHhNebV2k8hxXq9akfIc0uR27xVujtoOxOMPRkaNio7J72RxAPAFFF+tFP1aeetGVwvDA+gLAZxesmDrKJ7VJITT4Ae/UIONYsMzTczk22B0bvapaO5AaIVP3yth8HgnB0xGI+acJe2UdHEFrE4ckoAvAn7B64KzBsc6BPgqdwmkV6UgdTusUocIiHGz5j22l6jo8XcNC3v+e/3qayGqIxlzNSU+Rxz7GEO+pW9fh+w9ih8+PqLWpe3ZT77dyDDJstIXgYBf7Y9l4hWaDYQX210trklcasF4NMGWLSpCKcOltvUD+WMWClAz6QGF'
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
