{
  description = "Nix Flakes in PythonEDA";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:rydnr/pythoneda/0.0.1a5";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-python-packages = {
      url = "github:rydnr/pythoneda-python-packages/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-git-repositories = {
      url = "github:rydnr/pythoneda-git-repositories/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-nix-shared = {
      url = "github:rydnr/pythoneda-nix-shared/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Nix Flakes in PythonEDA";
        license = pkgs.lib.licenses.gpl3;
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-nix-flakes = pythonPackages.buildPythonPackage rec {
            pname = "pythoneda-nix-flakes";
            version = "0.0.1a1";
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = [ pkgs.poetry ];

            propagatedBuildInputs = with pythonPackages; [
              pythoneda.packages.${system}.pythoneda
              pythoneda-git-repositories.packages.${system}.pythoneda-git-repositories
              pythoneda-python-packages.packages.${system}.pythoneda-python-packages
              pythoneda-nix-shared.packages.${system}.pythoneda-nix-shared
            ];

            checkInputs = with pythonPackages; [ pytest ];

            pythonImportsCheck = [ ];

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
          default = packages.pythoneda-nix-flakes;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}