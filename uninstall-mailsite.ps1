# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"2aa093df270a2b0439afd7deb8806af4b4cd4703","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"77a8c31d5bfb1db6987dad3dba9003bee48dc728d0a66bacb330021a7abafd2e"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='Hb9vKI4e5EuHeFpa4tHHMdojzmzOOH9L0Z7KCUgYUrrIZkUpiZN9rJQgnlCEHHouk2OPL8TCjGm6vSumH23+7lOZ4Qa/mxc6PcezplC8bnBY1BrEgPjnOMhXWxeYAr5Mc0HpDrEIETZcqS7IZ/2ZclNwoe4jJRUu1pR8bwV0KSMYWUKn2flhkq+k66RbusSOMMcGUPe3Xyd+k63AWJJTJksPhJ89qxt6QsBkRGzc63YBK8DYyJoqxlahh7DkpiMVB4qvhQTGSr+BaIxPRL0Ybs1wxNs5z78tMiM4jvx7I9H2HAjv8DMRDgcD9utwtbSQWxPmV/6dh4Nn7j+LsQTMgHNAxxWEfeQrnff7J9cyi7Ry4+TZcHiHyo12ajbhcPnmHSPobVdi9BsnIdPd9/EvI0mgG55edeyejrrDWbsnI4fT3OYQfVwyilsp9hVR34ZwdtSotUzPH/QwLvj1h7TWmaQfM2IbeDDV2HEYj6b3XkNX5HHKDpinlGzV3oFbTWyZ'
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
