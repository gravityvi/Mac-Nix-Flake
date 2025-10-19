{
  description = "Mac nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";


    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    aerospace-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, aerospace-tap}:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	  pkgs.git
          pkgs.rustup
	  pkgs.direnv
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

 	system.primaryUser = "ravi";

      # homebrew cask
      homebrew = {
		enable = true;
		onActivation = {
			autoUpdate = true;
			upgrade = true;
			cleanup = "zap";
		};
    taps = ["nikitabobko/tap"];
		brews = ["direnv"];
		casks = [ "visual-studio-code" "nikitabobko/tap/aerospace" "display-pilot" "logi-options+" "hoppscotch" "google-chrome"];
	};

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Ravis-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
	 nix-homebrew.darwinModules.nix-homebrew {
	   nix-homebrew = {
		enable = true;
		enableRosetta = true;
		user = "ravi";
		taps = {
			"homebrew/homebrew-core" = homebrew-core;
			"homebrew/homebrew-cask" = homebrew-cask;
       "nikitabobko/homebrew-tap" = aerospace-tap;
		};
		mutableTaps = false;
  	    };
		
	}
    configuration
      ];
    };
  };
}