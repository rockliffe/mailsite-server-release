# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"97fb76fe6319b4db43014047c387db3bf5175051","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"39955becbef0f013d8feb53399f224c177c4eaca39f0e3a27fac8e903f6a8a01"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='UrfKiaLLqAILhzXtmYqic524rEu1t9HH2dXQNbIhYTH/VU9K+B2zKc5pYAFpvML0myIbqvFit45nWIfqicx3keNZtyA6FZ6qVd8BeeiYVuJrBqYdpRxcLdX7gLTe/7CTapm6CM/4wAfKA8YamwDizkTTTnEuZqV5vc2j06Aa4cr6dA99W2N/aNWOUUmhhN3rvykdLDQQ3sX3cqdkKjcgbh44xpF4Fp6M2bf8/C5Hk3AwhSbAPZYzE9kuLcq0ifVHALYnCYjQg1Aagds32dRMNimegDhDfnFBiox/YaOUK2UR0CRuhzkNvw5f0OqSPXiQ2CPycPBd3QVF1dwY56SYKYfPvR3ebdlRIq8Eoh743oH00bh2i+PfKFDqGTB3kg6FuMAs2bK9iIXV6qaGuBpnw9J8dNwM3G09E5JpzAsb0w1Ojlqt/l17AdCgx7pqriakYMNpzpRkrw7h7Z5yIfeyP/cKmFuID05x810YkDtSSH0S2qTI+Plfb0Gm63FhYqSl'
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
