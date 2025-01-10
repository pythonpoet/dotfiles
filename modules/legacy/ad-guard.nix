{ config, pkgs, ...}:{

services.adguardhome = {
    enable = true;

    settings = {
      bind_host = "0.0.0.0"; # IP of WireGuard interface (wg0)
      bind_port = 3000;
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "0.0.0.0:3000";
      };
      dns = {
	bind_host = "0.0.0.0";
	bind_port = "53";
        upstream_dns = [
          # Example config with quad9
          #"9.9.9.9#dns.quad9.net"
          #"149.112.112.112#dns.quad9.net"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
	   
	   "0.0.0.0:5335"
          # "127.0.0.1:5335"
        ];
	#rewrites = [
	# {
	#   domain = "cloud.david";
	#   answer = "192.168.0.26:10081";
	# }
	#];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
	"https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt" # Adguard list

	"https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing
	
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist

	"https://adguardteam.github.io/HostlistsRegistry/assets/filter_23.txt" # Windows spy blocker
      ];
    };
  };
}
