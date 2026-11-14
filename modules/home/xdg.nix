{ ... }:

{
xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"                = "vivaldi-stable.desktop";
      "application/xhtml+xml"    = "vivaldi-stable.desktop";
      "x-scheme-handler/http"    = "vivaldi-stable.desktop";
      "x-scheme-handler/https"   = "vivaldi-stable.desktop";
      "x-scheme-handler/about"   = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      # this one was added by codex/chatgtp desktop
      "x-scheme-handler/codex"   = "chatgpt.desktop";
    };
  };
}
