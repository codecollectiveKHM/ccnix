{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Weekly: drop generations older than 120 days, then hard-link identical files
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 120d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
