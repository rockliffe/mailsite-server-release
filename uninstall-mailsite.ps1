# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"a833c51e0e32ff9c117f7834d910069c9080c4c2","script":"uninstall","keyVersion":"v1","sourceSha256":"5cfcb4ef58b3f75680163a353876f831541a55d3139cb11a8ba78f0975fc9891","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"df226b1fbd2cfaa6470b4163463948e3707ab5383660786e4e28390906dd00a5"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='ZoO+zJHIpZ22PJ0+byZVGVQXdOqOazHcvqSQISlBq4r0A81tGgqvAGfVAhjAq43L1Ahd4UkRk8Eu2F2DFyhpIpvrm/yquDnW7a+KVGysUU1oAOGXSBm+jND5o7dpGBXQJvHrqG12XuScuh7Y4q3k+dw2abWVaW7OuYpNEBI2lMXXdec7XLhzesdHoAkKbRt69DOL6vdEfNBfMwM9YEmBUl2wgLgZFP4C3n5xCG35zgY9Edl9SWr7jzrzwHG65oUmnWBDjb8R2QHCQ4b4zH1WRYGvaM3xRWdxA+ZpuYSi7co8NRrMn4+AAD2eoMK/j6JdAZtJTehaZ1LKlef06CB6fPrcLFJJ/hE+xgCoBVja9IWj2cGOutYYES8+eKQLlDitz6KQ++nUmu7o3RrccvYqU8mbYICpJchS5gOPz+HJwQEclMyEMI/wF1m2oO3C7OFKM5ZtPKWPNeoRynWXeWTLG4i0IQBy6xyG9C7Lwo2z6PRYLc1UXdEZz8eo35bGGUUY'
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
