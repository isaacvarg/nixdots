{ pkgs, llm-agents, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agents = llm-agents.packages.${system};

  claude-desktop = pkgs.symlinkJoin {
    name = "claude-desktop-wrapped";
    paths = [ agents.claude-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude-desktop \
        --set GIT_SSH_COMMAND "ssh -F ~/.ssh/config"
    '';
  };
in
{
  home.packages = [
    claude-desktop
    agents.claude-code
    agents.codex
    agents.chatgpt
    agents.hermes-desktop
  ];
}
