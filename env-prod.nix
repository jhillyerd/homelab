let
  hw = import ./hw { dnsDomain = "skynet.local"; };
in
{
  nexus = hw.kvmGuest {
    name = "nexus";
  };
}
