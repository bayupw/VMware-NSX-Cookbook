# NSX Variables
$NSXUsername = "admin"
$NSXPassword = "VMware1!"
$NSXManager = "https://nsxmgr-01a.corp.local"
$NSXURI = "/api/2.0/vdn/scopes/vdnscope-1/virtualwires"

# NSX Authorization Header
$NSXAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($NSXUsername + ":" + $NSXPassword))
$NSXAuthHeader = @{"Authorization"="Basic $NSXAuth"}

# NSX XML Body Payload - typeast to [xml]
[xml]$XMLBody = "<virtualWireCreateSpec>
  <name>PowerShell-Logical-Switch</name>
  <description>Logical Switch created from PowerShell</description>
  <tenantId>PowerShell Tenant</tenantId>
  <controlPlaneMode>UNICAST_MODE</controlPlaneMode>
  <guestVlanAllowed>false</guestVlanAllowed>
</virtualWireCreateSpec>"

# Add code to allow untrusted SSL certs - taken from https://d-fens.ch/2013/12/20/nobrainer-ssl-connection-error-when-using-powershell/
Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@ 
[ServerCertificateValidationCallback]::Ignore();

# REST API Call via Invoke-WebRequest cmdlet
$response = Invoke-WebRequest -Uri "$NSXManager$NSXURI" -Method:Post -Body $XMLBody -Headers $NSXAuthHeader -ContentType "application/xml" -ErrorAction:Stop -TimeoutSec 180
Write-Host "$response"