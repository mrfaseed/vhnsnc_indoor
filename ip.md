class Config {
  static const String baseUrl = "http://10.162.200.8/vhnsnc_indoor";
}
Get-NetIPAddress -AddressFamily IPv4 | Select IPAddress, InterfaceAlias

Wifi

class Config {
  static const bool isEmulator = true;

  static const String baseUrl = isEmulator
      ? "http://10.0.2.2/vhnsnc_indoor"
      : "http://10.162.200.9/vhnsnc_indoor";
}

