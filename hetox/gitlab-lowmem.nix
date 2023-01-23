{

  ## see https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.gitlab = {
    puma.workers = 0;
    extraConfig = {
      sidekiq.max_concurrency = 10;
      prometheus_monitoring.enable = false;
      gitlab_rails.env.MALLOC_CONF = "dirty_decay_ms:1000,muzzy_decay_ms:1000";
      gitaly.env.MALLOC_CONF = "dirty_decay_ms:1000,muzzy_decay_ms:1000";
      gitaly.env.GITALY_COMMAND_SPAWN_MAX_PARALLEL = "2";
      gitaly.cgroups_count = 2;
      gitaly.cgroups_mountpoint = "/sys/fs/cgroup";
      gitaly.cgroups_hierarchy_root = "gitaly";
      gitaly.cgroups_memory_enabled = true;
      gitaly.cgroups_memory_bytes = 500000;
      gitaly.cgroups_cpu_enabled = true;
      gitaly.cgroups_cpu_shares = 512;
      gitaly.concurrency = [{
        rpc = "/gitaly.SmartHTTPService/PostReceivePack";
        max_per_repo = 3;
      } {
        rpc = "/gitaly.SSHService/SSHUploadPack";
        max_per_repo = 3;
      }];
    };

  };

}
