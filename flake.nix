{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    largescaleobjects.url = "github:jcai849/largescaleobjects";
  };
  outputs =
    {
      nixpkgs,
      utils,
      largescaleobjects,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        largescalemodels = pkgs.rPackages.buildRPackage {
          name = "largescalemodels";
          version = "1.3";
          src = ./.;
          propagatedBuildInputs = [
            largescaleobjects.packages.${system}.default
            pkgs.rPackages.biglm
          ];
        };

        prod_pkgs = [ largescalemodels ];
        dev_pkgs = prod_pkgs ++ [ pkgs.rPackages.languageserver ];

        R_dev = pkgs.rWrapper.override { packages = dev_pkgs; };
        radian_dev = pkgs.radianWrapper.override { packages = dev_pkgs; };
        radian_dev_exec = pkgs.writeShellApplication {
          name = "r";
          runtimeInputs = [ radian_dev ];
          text = "exec radian";
        };

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-medium inconsolata;
        };

        bundle = pkgs.stdenv.mkDerivation {
          name = "orcv-bundle";
          nativeBuildInputs = [ R_dev ];
          src = ./.;
          buildPhase = ''
            mkdir -p $out
            R CMD build .
            cp *.tar.gz $out/
          '';
          installPhase = "true";
        };
        check =
          pkgs.runCommand "check"
            {
              nativeBuildInputs = [
                R_dev
                tex
                pkgs.html-tidy
              ];
              buildInputs = [ bundle ];
            }
            ''
              mkdir -p $out
              R CMD check --as-cran ${bundle}/*.tar.gz
              check_success=$?
              cp -r *.Rcheck $out
              exit $?
            '';

      in
      {
        packages = {
          default = largescalemodels;
          bundle = bundle;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            R_dev
            radian_dev_exec
          ];
        };
        checks.default = check;
      }
    );
}
