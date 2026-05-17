{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bind
    iperf3
    lsof
    netcat-openbsd
    nmap
    tcpdump
    traceroute
  ];
}
