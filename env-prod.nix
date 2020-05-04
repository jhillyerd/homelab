let
  hw = import ./hw;
in
{
  nexus = hw.kvmGuest {
    name = "nexus";
    ip = "192.168.1.11";
  };
}
