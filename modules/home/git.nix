{ ... }:

{
  programs.git = {
    enable = true;


    settings = {
      user = {
        name = "Isaac Vargas";
        email = "hello@isaacvargas.dev";
      };

      init.defaultBranch = "main";

      core.editor = "nvim";

      # pull.rebase = false;
    };
  };
}
