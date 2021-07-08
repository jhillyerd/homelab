# NOTE:
#   You must run `nixops set-args --arg-str environment prod` before the
#   initial deploy of the prod environment.

let
  hw = import ./hw;
in
{
  nexus = hw.msiCubi {
    name = "nexus";
    ip = "192.168.1.10";
  };
}
