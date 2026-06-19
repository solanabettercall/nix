{
  byMachine = {
    ares = "xorek";
    hermes = "virtualbox";
  };

  definitions = {
    xorek = {
      knownProviderIds = [ "xorek" ];
    };

    virtualbox = {
      knownProviderIds = [ "xorek" "virtualbox" ];
    };
  };
}
