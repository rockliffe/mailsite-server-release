# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"fc11870c7f07b0f29475cb649897fa1be79cef31","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.com/api/installer/key","cacheId":"9fce424ddcdf1ddfde2c4327d609217c9b607ae3cc4839f249ccb747b5713432"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='AXINeXVDyvX7s66a5ZX3vs5rGt5sgggBwNhaa/e6jto5CsBoPbs6syxAjjxjty3nlgKkFm+YfLLcaeK4UmXOB0+gtQvSTsluaRmJ0DwuRNTAyporGsxk2Nxdvq8CrK/Rp8+qv0JIrE3Z6jaZRjiGm6jE8QqAuDN0IAyng9HNTrbiOWJrZhacAfbHK6QHeWKLWCtx+boRzdCRSP66DW1bxkN7bCo47BYbBjh0GDbEx7dbN3S2ws36+cZkjbQC093EVhSOv8J9jvlVY8hI6yx9iHOja9JDlujOcUK2g6N9/zdubF4OlnPfRugNRQXiVR1sBhHYviVnTbFFPrb17zNybWUjXSMialj8Mel08uob0YYHVG+6kKIgMidzBNmbRLtt0skqE4qHPakSrKFYRvrpuCRUBlXkTnC72awIV71+jHWCVwdwikjsmrA93BFMT5eWWQFRRfV6UxpmGV9miOtJZyaw5DvnE4PMiUHhTVY6GVdlde59SS2f9tPuPEALSQ3U'
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
