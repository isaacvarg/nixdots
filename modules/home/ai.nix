{ pkgs, llm-agents, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agents = llm-agents.packages.${system};
in
{
  home.packages = [
    agents.claude-desktop
    agents.claude-code
    agents.codex
    agents.chatgtp
  ];
}
