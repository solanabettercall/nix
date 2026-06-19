{
  subnets = {
    wg-mesh = {
      address = "10.77.0.0";
      prefixLength = 24;
    };

    awg-exit = {
      address = "10.78.0.0";
      prefixLength = 24;
    };
  };

  allocations = {
    wg-mesh = {
      machines = {
        ares = 2;
      };
      clients = {
        bubble-home = 10;
      };
    };

    awg-exit = {
      machines = {
        ares = 1;
      };
      clients = {
        bubble-home = 10;
      };
    };
  };

  staticIpv4.byMachine = {
    ares = {
      interface = "ens3";
      prefixLength = 32;
      gateway = {
        address = "172.0.0.1";
        interface = "ens3";
      };
    };

    hermes = {
      interface = "enp0s3";
      prefixLength = 24;
      gateway = {
        address = "192.168.10.1";
      };
    };
  };
}
