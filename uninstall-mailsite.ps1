# Generated encrypted MailSite installer. Readable sources stay in the private repository.
[CmdletBinding()]
param([string]$InstallDir,
[switch]$DeleteData,
[switch]$Yes)
$__miMetadata = '{"version":1,"commit":"5d5695bfd620aad02173b12c81b1deab4a237c99","script":"uninstall","keyVersion":"v1","sourceSha256":"1ba42e1c4baafdad182f55c8f4093cbef34877aba1bae5f795e850e515841f93","endpoint":"https://mailsite.dev/api/installer/key","cacheId":"66fcd0e1e5f28fa4844caaf8f18e8099ee2e3af0d262ecaf97a4d4e06ece0047"}' | ConvertFrom-Json
$__miPayload='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'
$__miSignature='CxOXRaUmEUs3QTDFtvCH/OfPESfJSUCVDQ/vPTdi30fw3sTwOqvrB2LgqKmWSd7uaTzg/7+PBq77mPPkRS2RpYLUKhfa6W2EUoZWFy8jJZyyTxkGyCWjIWVlmRqbvwAApVQZ/amsfTSB55o2ck/fQIrRqhpNg01gkXWUY9j3zWVU8QRag6Rm3scVTyh/dc6mfSsehwvDP9KwCJt/74720jN0lLblMhgSU8lmV/ZE/2knvzfVrTdqnzi+sObJ6GdjlDLkW3LLy7wFWe8791Q/sfOecuP84exnLsQ3x6CcUvx4h1npWMv2iTAQ8b7EgRZalD+wpBD6LSH+Dbw1V2I3DIicDBKGU9qpurblp45PTCpIWFcHz9vnuD9gkj8H6StAoezuZPtoXjVAjUZVnYlPgzuB2d+ZQTOUFTwgH2vqxLm0aFe8g7mfGXsW656Ce39MHm5/7I5rOZhvusunOCGGDCW5LkcBFS8dve76AqIIyfqpUTJ9ZWoN8O2wqhTk8INm'
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
