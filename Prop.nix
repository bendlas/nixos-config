let
  registry = {

    machine.hetox.stability = "stable";

  };
in group: field: attribute: default:
  registry."${group}"."${field}"."${attribute}" or default
