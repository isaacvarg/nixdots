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

    strata = {
      url = "github:lgse/strata";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim.url = "github:pfassina/lazyvim-nix";

    llm-agents.url = "github:numtide/llm-agents.nix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    lazyvim,
    llm-agents,
    nix-flatpak,
    sops-nix,
    strata,
    ...
    }: {

    # latte system == home computer
    nixosConfigurations.latte = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit strata; };

      modules = [
        ./systems/latte

        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        sops-nix.nixosModules.sops

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
	        home-manager.extraSpecialArgs = {
		        inherit lazyvim llm-agents nix-flatpak strata;
	        };

          home-manager.users.isaac = {
            imports = [
              ./users/isaac.nix
              ./bundles/home/common.nix
              ./bundles/home/desktop.nix
              ./bundles/home/development.nix
              ./bundles/home/productivity.nix
            ];
            my.ssh.onePasswordKeys = [ "nixos#latte" ];
          };
        }
      ];
    };


    # oolong system == work computer
    nixosConfigurations.oolong = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit strata; };

      modules = [
        ./systems/oolong

        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
	        home-manager.extraSpecialArgs = {
		        inherit lazyvim llm-agents nix-flatpak strata;
	        };

          home-manager.users.isaac = {
            imports = [
              ./users/isaac.nix
              ./bundles/home/common.nix
              ./bundles/home/desktop.nix
              ./bundles/home/development.nix
              ./bundles/home/productivity.nix
            ];
            my.ssh.onePasswordKeys = [ "nixos#oolong" ];
          };
        }
      ];
    };

  # matcha system == htpc
  nixosConfigurations.matcha = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./systems/matcha
      home-manager.nixosModules.home-manager
      nix-flatpak.nixosModules.nix-flatpak
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit lazyvim llm-agents nix-flatpak; };
  
        home-manager.users.isaac.imports = [
          ./users/isaac.nix
          ./bundles/home/common.nix
        ];
      }
    ];
  };

  };
}
