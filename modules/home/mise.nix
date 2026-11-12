{ ... }:

{
  programs.bash.enable = true;

  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    mutableSettings = true;

    globalConfig = {
      settings = {
        experimental = true;
        all_compile = false;
      };
    };
  };
}
