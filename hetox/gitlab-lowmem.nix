{ pkgs, ... }:
{

  ## see https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html
  ## see https://techoverflow.net/2020/04/18/how-i-reduced-gitlab-memory-consumption-in-my-docker-based-setup/

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.gitlab = {
    puma.workers = 0;
    extraEnv = {
      LD_PRELOAD = "${pkgs.jemalloc}/lib/libjemalloc.so";
      # ENABLE_RBTRACE = "1";
      RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO = "0.001";
      RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO = "0.02";
      ## https://github.com/jemalloc/jemalloc/blob/dev/TUNING.md
      MALLOC_CONF = "background_thread:true,dirty_decay_ms:5000,muzzy_decay_ms:5000,narenas:1,lg_tcache_max:13";
    };
    extraConfig = {
      prometheus.enabled = false;
    };

  };

}
