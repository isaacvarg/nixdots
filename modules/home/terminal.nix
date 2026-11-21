{ config, ... }:

{
	programs.ghostty = {
      enable = true;

      settings = {
        # colours rendered by skwd-wall from the wallpaper (skwd-wall.nix);
        # the leading ? makes it optional before the first render
        config-file = "?${config.xdg.cacheHome}/skwd-wall-v2/ghostty.conf";
        background-opacity = 0.80;
        window-padding-x = 25;
        window-padding-y = 25;
        cursor-style = "block";
        cursor-style-blink = true;
      };
  };
}
