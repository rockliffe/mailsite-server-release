# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"de8e99f78b83e4f91629f8051e5128e8b2719459","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.com/api/installer/key","cacheId":"cea769ac389492b0799f776a67b7919e8de08a1d15c8499b8245f6e6a986a88a"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='Ay6SvUBHVaNxsZ9wu/db8DYxnkmokUES1qM8wdoMX+KIABZlRSXiEz9LeR/+Y+Z5P3mX44bTayFl/Pn2EnDlzsm+O3u8mENfAN3TKwJ0QzkVXLorAqvnLa8/8KSaFp/UAUz9yk2Vxkyb0HUkceS6zk4JTTHrwvbOZ19+JiN3szDvZ+JtToRL4TL0sATJJZ2UqqqyWUVN/kx4Gp6BdAaACuO8uO+H87GdkV04Tyei/+2dF1HosTjI0Z5vf0npXub+AAWl/tdFoHqhL3ZSVBIRi3lbW+fSLCCY+HTf/NJuZrVjzcUM/IsakSFlY5I001dsUuOLEp/KdMJOh2IfnM6RSGVhLKmG/cjTQWEg6ygmK0GEz6MTFZgNiOSYXUatcV4XXEHDaJ+LCZUpX9M05DK9hmwFygPIO5fIfbF/+V53M2Q1j0qMYVusN043os5gmapBoYO2t6lmSZLKPqng6fK0U/vkEGrUEECT/kheJQb3pu/uDDIuxqqytfbRqfXtGRyd'
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
