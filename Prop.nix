let
  registry = import ./Registry.nix;
in group: field: attribute: default:
  registry."${group}"."${field}"."${attribute}" or default
