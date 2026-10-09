# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"6a17352de58fdcde67dcb3f08e457f07d5b87ce9","script":"uninstall","keyVersion":"v1","sourceSha256":"7687998679849203924ad28d279d573daa1f606f0f7597c7ab1a7b74b53a2aae","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"2074d9646e957d224d61958124039a4da1ff20e44efe5212aedc200195dfda38"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='IiczEwFfc+uJ2IfErVsDggzWjjejs6MFHoQ1ue1TS8dkhcTdfkWOX42YjZQ8BgNuF40dEVmSmWIOlrHRvtFjmxxjl2DHGY1VrGsBWowZVyWcl6gql1zqplka+nwqTtKzHc0EaFwFZ9KvzFc3JZN2kpG4hhJf0xVb11HIXUkGkh/AYf7UqOsHXXhhnGm5rWc3y2JygrhqXDnPleRj5rh1pev5/0wOnadfC4JC8G8khgEZEj3dppTJP0xnJmSmKOPQs9BscwdCGdFJ4/SBB2jNfkR3cFDQugApG5Bu6KeW8Pcn+QamQ0z58NP25fQV8ObrjjZOxfseBLmdkXu02bBak7HOVm3oZ+YplCYttXEMQWj4PpMP/5/ivy+l85Ll49GCRmUkL6X+x2GtQVmAKDnkm9ix33AHzquyiji15nKt68xrUkH913FlYPqCOE5+5h7gjpH+qRnOym666xA9qyhjDz8HuIjRywj9OQIpkiI1f2EDAUOoU94m2cbk58pcPts8'
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
