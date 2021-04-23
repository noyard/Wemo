function Set-WemoOff
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ipAddress
    )
    $port = "49153"
    $url = "http://$($ipAddress):$($port)/upnp/control/basicevent1"
    $body = @"
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1">
            <BinaryState>0</BinaryState>
        </u:SetBinaryState>
    </s:Body>
</s:Envelope>
"@

$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port)
if ($connection.Connected) {
    Write-Host "Wemo is online"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
    $result = Invoke-WebRequest -Uri $url -Body $body -ContentType "text/xml" -Method POST -Headers @{"SOAPACTION" = "`"urn:Belkin:service:basicevent:1#SetBinaryState`""}
    return $result
} else { 
    Write-Host "Failed to connect to Wemo" 
    return 404
}
}

function Set-WemoOn
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ipAddress
    )
    $port = "49153"
    $url = "http://$($ipAddress):$($port)/upnp/control/basicevent1"
    $body = @"
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1">
            <BinaryState>1</BinaryState>
        </u:SetBinaryState>
    </s:Body>
</s:Envelope>
"@

$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port)
if ($connection.Connected) {
    Write-Host "Wemo is online"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
    $result = Invoke-WebRequest -Uri $url -Body $body -ContentType "text/xml" -Method POST -Headers @{"SOAPACTION" = "`"urn:Belkin:service:basicevent:1#SetBinaryState`""}
    return $result
} else { 
    Write-Host "Failed to connect to Wemo" 
    return 404
}
}


