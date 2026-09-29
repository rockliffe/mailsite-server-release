# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"9917e819bd454dfa7a3e2747f7b541ca8182f6dc","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"0ef4815ed8edf908330146959dcf3e3f802acb825ccbbfe7e0c441e011757aee"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='HvN0PSiV4J98PFbMr7+mzd3fR9aXdwP+J40e0QWgVSig9nQsyXXQwbrKTDQ5c6zDePihwWvFuma4zrtfKQ0q1rrTF+EfXLnarIOaCPdx+0q2vzg09wtYxh8zXsSj3M2QI93Gf/Y5S82CFy6I0OAXyxW+N62RXxF/S3B+kQFnxePCzLwFSMiqf6/XcBOWA4ajiS7y+67KjZHPb3RsDuHJaqN03mR/WX/yutyLwsogwFCYgJofyJCqdufQdBluyPoKVGGIz1zzXTN6W+LX9EVbAk5Zdkgj/trME5ga5JNdcpwh+3vxA+E3CnnDAfOC3sA2N9iOc1OseyL2KbJ3HLrVYTboTS8CgFC9mtPxNTwaSxZgNUiC2npy6C8VP6D9XtQ6hSFRhs4t5+SNaUWQtUVv2D8/i89txns73fOsf4Gr8BUfTZ8yStsmxUYuM/+FKT826u5KrcShWYcPHd62/qp66ORHM2wIMD47eG7jGYEasGTOlmikI20au7mESSAy7oub'
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
