{ pkgs, ... }:

{
  programs.localsend = {
    enable = true;
    openFirewall = true;
    # The nixpkgs build of localsend 1.18.0 links libz.so.1, but zlib is
    # missing from the binary's RUNPATH. The app exits at launch with
    # "libz.so.1: cannot open shared object file". This wrapper adds zlib to
    # LD_LIBRARY_PATH, which avoids rebuilding the Flutter app from source.
    #
    # When nixpkgs fixes the package, delete this package block so the module
    # uses pkgs.localsend again, and drop pkgs from the function arguments.
    # To check for the fix, run `ldd` on app/localsend/localsend_app in the
    # localsend store path. If libz.so.1 resolves, the wrapper is unneeded.
    package = pkgs.symlinkJoin {
      name = "localsend-${pkgs.localsend.version}";
      paths = [ pkgs.localsend ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/localsend_app \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.zlib ]}
      '';
    };
  };
}
