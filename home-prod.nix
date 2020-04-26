let
  hw = import ./hw { dnsDomain = "skynet.local"; };
in
{
  webserver = hw.kvmGuest {
    name = "webserver";
  };
}
