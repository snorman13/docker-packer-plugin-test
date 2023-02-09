<powershell>
  # Get public hostname
  $hostname = Get-EC2InstanceMetadata -Category PublicHostname
  # Remove any existing Windows Management listeners
  Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
  # Create self-signed cert for encrypted WinRM on port 5986
  $Cert = New-SelfSignedCertificate -Subject "CN=$($hostname)" -TextExtension '2.5.29.37={text}1.3.6.1.5.5.7.3.1'
  $valueset = @{
      Hostname              = $hostname
      CertificateThumbprint = $Cert.Thumbprint
  }

  $selectorset = @{
      Transport             = "HTTPS"
      Address               = "*"
  }
  # Add listener for encrypted WinRM on port 5986
  New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset
  # Configure WinRM
  cmd.exe /c winrm quickconfig -q
  cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
  cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
  cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="false"}'
  cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="false"}'
  cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
  cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
  cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
  # Add firewall rule for WinRM
  cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
  cmd.exe /c netsh advfirewall firewall add rule name="WinRM-HTTPS (5986)" dir=in action=allow protocol=TCP localport=5986
  # Restart WinRM service
  cmd.exe /c net stop winrm
  cmd.exe /c sc config winrm start= auto
  cmd.exe /c net start winrm
  </powershell>
