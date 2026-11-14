{ pkgs, ... }:

{
  home.packages = [ pkgs.vivaldi ];
  home.sessionVariables.BROWSER = "vivaldi";
}
