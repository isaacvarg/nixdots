{
  description = "NixOS Configuration";

  # for nimtide cache, let system know before builds
  # so it is utilized
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
    ];

    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim.url = "github:pfassina/lazyvim-nix";

    llm-agents.url = "github:numtide/llm-agents.nix";
  };
  
  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    lazyvim,
    llm-agents,
    ... 
    }: {

    # oolong system == work computer
    nixosConfigurations.oolong = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./systems/oolong

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
	        home-manager.extraSpecialArgs = {
		        inherit lazyvim llm-agents;
	        };

          home-manager.users.isaac = {
            imports = [
              ./users/isaac.nix
              ./bundles/home/common.nix
              ./bundles/home/desktop.nix
              ./bundles/home/development.nix
            ];
          };
        }
      ];
    };
  };
}
