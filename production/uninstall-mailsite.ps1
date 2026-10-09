# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"6a17352de58fdcde67dcb3f08e457f07d5b87ce9","script":"uninstall","keyVersion":"v1","sourceSha256":"7687998679849203924ad28d279d573daa1f606f0f7597c7ab1a7b74b53a2aae","endpoint":"https://mailsite.com/api/installer/key","cacheId":"bc384b78f2a4e527fedce6594d95e745762be7c3cf56f840e6208a8983502f53"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='Jqrp/vyJ3M+eMcv9zIMvEUuEbqzDu9DJLe3ZRCtSVqQAXvIgnFBNuq8xhZklPCvru44WPOKb9wH6sQmvMkD+giyHHdxL/Qss0a+rMGekhVRwQAoIlvKJH83HQ0Lq2j23q5l84DAV1+zfPcm6NmR/p2CPFHIETfzr2NsPMWu5XpepZe2Em1ZZJGO1ByQ2FbV6L1hqQ3lAhHAtfCUGeeZy26hQ3Ug1ARt0GvCz0AJ6P+cU+u0CtBzBZiPXwsVvOKmASXGyeN9GHSgzzeUm5xBAtCp1eI5HL4KfA20QlED60sRClqx109NqFMddjgkBXb+XXEcbWTlHGzy33ZelNj4NP4XuxJBn7eY45gAzCj9TajCpfIiJwMSrR5l0tCE+WbW0HYEeL418bK2mHuvVKDGlP0kKV9eGw9c0MX4Mn1T1LQS1k3tlBYetEAMBRhkkQEx7BDbGB62ATarLZPrnPs8klwC7JTXEHW7AllDieZCOMryYP39XS2tznuDNhaNAMG5H'
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
