# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"d8c0541151b82a7b447e2aa9aab77a31652db389","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"bc66aefc4e9c0ec13f5af42f49d1ab27a6be22dd41835fc78208c56de9d2b907"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='kaFRSG2S+2KwFSudchKLGjxUOFyAaUnDUfK/Ci6B7wZ7YfsjNBfRGFROJ0uUkz25yFc0XPeF3d7hVchFTuOMUiQ2XJ+sNge2YuhBsHT+dK60Ui5mz8ltAwkSt+8IxprvVBQiq0LkHBvUOVq9UI09W+/9R2NEMLhtPUyB6IaH/JniiDEoXRI5dcDkVKu3eClNps4hrn/UXiTo/mEGjWHHnOJDxWc5IXWfzz05wwE+dQyPESz9NEgpDPIrhMe1oPYRqM+N9QDw0unOZgkAk40jK6eepEoiR2nO8PNEl1KMKO0h4SmmHaBKfmcmKaMAgik+El3MfTFjc67uBfehram0uTBVVqw281M058qPscI5Qt2DdASxVpccEN//0uUe1TWyEAoPCjcul5yMugLs909y0x3BNE5YfADLqc5gORelVkqhgDmOO/cAbQ2EyUnGRsMVkGA40G7cqPx/MxqUw5AXUURkkdub4rT4AHlsuRYRJQT7Z0p2hm5G5terC9v5EG9R'
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
