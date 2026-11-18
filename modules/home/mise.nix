{ ... }:

{
  programs.bash.enable = true;

  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    mutableSettings = true;

    globalConfig = {
      tools = {
        go = "latest";
        python = "3.13";
        rust = "stable";
        node = "lts";
        pnpm = "latest";
      };

      settings = {
        experimental = true;
        all_compile = false;
      };
    };
  };
}
