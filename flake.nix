{
  description = "Example Darwin system flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager, ... }@inputs:
  let
    system = "aarch64-darwin";

    nixpkgsConfig = {
      config = { allowUnfree = true; };
    };

    pkgs = import nixpkgs {
      system = system;
      overlays = [inputs.neovim-nightly-overlay.overlays.default];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#14m3
    darwinConfigurations."14m3" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager {
          users.users.sebastorama = {
            name = "sebastorama";
            home = "/Users/sebastorama";
          };
         home-manager.useGlobalPkgs = true;
          home-manager.users.sebastorama = import ./home.nix;
        }
      ];
      specialArgs = { 
        inherit inputs;
        system = system;
        self = self;
        pkgs = pkgs;
      };
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."14m3".pkgs;
  };
}
