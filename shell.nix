let sources = import ./nix/sources.nix;

in { pkgs ? import sources.nixpkgs { } }:

with pkgs;
with lib;

let dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_5_0 ];

in mkShell {
  name = "env";
  buildInputs = [ niv dotnet-combined omnisharp-roslyn ];

  shellHook = ''
    export DOTNET_ROOT=${escapeShellArg dotnet-combined}
  '';
}
