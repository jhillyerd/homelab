# Common config shared among all machines
{
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  time.timeZone = "US/Pacific";

  system.stateVersion = "20.03";
}
