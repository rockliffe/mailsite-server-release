# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"b84c57381139b79ba0e8b78d1a9b9dc0ea6f6205","script":"uninstall","keyVersion":"v1","sourceSha256":"1e88f0c6dcd3a26ba6eefa149fe4fb0a7a6a502145de0ae7466df772ad742d5e","endpoint":"https://mailsite.com/api/installer/key","cacheId":"f3fbaae2535aac080f2cf635b7d0b16dfae13c7e9cac9b202003c1d9fafbfc10"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='TvSxXYnMWZ3EK3MyMGeSC0UNkN5fT2HZhD8761IKS4JgsXELze+bYOQCctblmHtpakvW5Ork2CMFDa/G9Fx4t0XPD5Bf7VoehG22BSsbJeM+BH7bYc6zIgBi9yOdZc42r07GavCzvWRFiTSZ5n2HagR6eluRMmXF85djnW0eux0mEfnQlI+M/R+94ysxo7GLhqFLhnadTHItdv2UOrpJFIFhFGdql7BKvDGZ+g/BtfkFQss7OE2tSuF8OkE12b3zqzpzVvO4IKmKElmf/5DPWRV2oh/x7pSzr/o1xhT5t+xdL0FZ9+NWBAv56sC0e9preWerFtPdoQczcriy727bZfsuGnk6hZik7eO+3NFX4le0X9iKU4xADj7eABi90SpcMDbf7FXSS8/OJYpW1TbHvKlI8iblbY+bwtEHhV9dVdhKKcbT9tuTsKDhFthsR2SceTMygnomgz1yzre06WLwnH1OLqXituhtQP2n5ASeTePCy/D2xWqoVZ/AzN7sb9g5'
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
