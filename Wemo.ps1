function Get-IpPort
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ipAddress,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Port
    )

    $ErrorActionPreference = "SilentlyContinue"

    # Create TCP Client
    $tcpclient = new-Object system.Net.Sockets.TcpClient
    
    # Tell TCP Client to connect to machine on Port
    $iar = $tcpclient.BeginConnect($ipAddress,$port,$null,$null)

    # Set the wait time
    $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)

    # Check to see if the connection is done
    if(!$wait)
    {
        # Close the connection and report timeout
        $tcpclient.Close()
        $ErrorActionPreference = "Continue"
        if($verbose){Write-Host "Connection Timeout"}
        Return $false
    }
    else
    {
        # Close the connection and report the error if there is one
        $error.Clear()
        $tcpclient.EndConnect($iar) | out-Null
        if(!$?){if($verbose){write-host $error[0]};$failed = $true}
        $tcpclient.Close()
        $ErrorActionPreference = "Continue"
    }

    # Return $true if connection Establish else $False
    if($failed){return $false}else{return $true}
}

function Get-Wemo
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ipAddress
    )
    #depending on device and firmware, a WeMo can listen on a number of ports
    $ports = (49152,49153,49154,49155)

    $Wemoport=$null
    foreach ($port in $ports)
    {
        if(Get-IpPort $ipAddress $port) {
            "Wemo is online at $($port)"
            $Wemoport = $port
        }
    }

    if ($null -ne $Wemoport){
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

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
        $result = Invoke-WebRequest -Uri $url -Body $body -ContentType "text/xml" -Method POST -Headers @{"SOAPACTION" = "`"urn:Belkin:service:basicevent:1#SetBinaryState`""}
    }else{
        "Wemo offline"
    }
}

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


