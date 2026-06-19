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
  ipv4 = rec {
    subnet24Cidr = subnet: "${subnet.address}/${toString subnet.prefixLength}";
    addressInSubnet24 = subnet: hostNumber:
      let
        parts = splitSubnet24 subnet;
      in
      "${parts.a}.${parts.b}.${parts.c}.${toString hostNumber}";
    machineAddress = inventory: subnetId: machineId:
      let
        subnet = inventory.network.subnets.${subnetId};
        hostNumber = inventory.network.allocations.${subnetId}.machines.${machineId};
      in
      addressInSubnet24 subnet hostNumber;
    clientAddress = inventory: subnetId: clientId:
      let
        subnet = inventory.network.subnets.${subnetId};
        hostNumber = inventory.network.allocations.${subnetId}.clients.${clientId};
      in
      addressInSubnet24 subnet hostNumber;
    isSubnet24 = subnet: subnet.prefixLength == 24 && splitSubnet24 subnet != null;
  };
}
