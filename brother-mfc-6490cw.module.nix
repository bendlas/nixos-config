{

  imports = [
    # <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan5.nix>
  ];

  hardware = {
    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          brother = { model = "MFC-6490CW"; nodename = "BRN001BA95F5BCC.local"; };
        };
      };
    };
  };

}
