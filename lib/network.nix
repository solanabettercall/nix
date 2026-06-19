_:
let
  splitSubnet24 = subnet:
    let
      parts = builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.0" subnet.address;
    in
    if parts == null then null else {
      a = builtins.elemAt parts 0;
      b = builtins.elemAt parts 1;
      c = builtins.elemAt parts 2;
    };
in
{
  ipv4 = {
    subnet24Cidr = subnet: "${subnet.address}/${toString subnet.prefixLength}";
    addressInSubnet24 = subnet: hostNumber:
      let
        parts = splitSubnet24 subnet;
      in
      "${parts.a}.${parts.b}.${parts.c}.${toString hostNumber}";
    isSubnet24 = subnet: subnet.prefixLength == 24 && splitSubnet24 subnet != null;
  };
}
