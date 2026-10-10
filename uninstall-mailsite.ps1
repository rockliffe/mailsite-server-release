# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"fc11870c7f07b0f29475cb649897fa1be79cef31","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"da41dfcfbf5702c48a65b5849a1a9ea551b31f3ade145b7fe1f87d0566f1b923"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='TZkcUXFJnQEG1qaTgGTooivjNaTM56YVuaGOScN08PaP5ILHnB0zvt9bFcdJxIZtXWhTMensXx0Ax1A8XnC5hh/TlqljDXzcFaSQPAac0bP6h/7/jsBS+SPNvsWXzdBnAriqy5o1OA0dRRqAEZR7tpONJqie9m8sqPbT2iZbDYJQMX9Pt+8Ini4VJc5OawuzDN2bvPi2Vgc6r/Ei2ma3/L5ndBxMgFWMKr+PJ+xfGusjepBA6cKs3h2GcLzOW2ImHtfOPW2EwxXARh9CJT51dDzlas2TsTfSYRTOOcO6qyIf+gTrPuHVs5U6OOeWz0jfHQwZUTcxUqePH+ytGIVpki+5hrXFpty0aDcY3dP+YmmDF4tX5wSSg6bW3gG0VIZyyWWaH9KrWhlvtnIUDDwoKS9Oroj6bS2fCSbYQMojv25HFmqkgC1J7a2t3JuHzXf3pc/bFGznsd61tT00GptdNqZR10JhJiKKrZAX+ZroWEtlN/oW8J7nEWn3kl3ONC2u'
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
