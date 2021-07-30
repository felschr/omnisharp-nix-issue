let sources = import ./nix/sources.nix;

in { pkgs ? import sources.nixpkgs { } }:

with pkgs;
with lib;

let
  dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_5_0 ];
  dotnetRoot = "${dotnet-combined}";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/bin/dotnet";

in mkShell {
  name = "env";
  buildInputs = [ niv dotnet-combined omnisharp-roslyn ];

  shellHook = ''
    export DOTNET_ROOT=${escapeShellArg dotnetRoot}
    local dotnetBase=${escapeShellArg dotnetSdk}/$(${
      escapeShellArg dotnetBinary
    } --version)
    export MSBuildSdksPath=$dotnetBase/Sdks
    export MSBUILD_EXE_PATH=$dotnetBase/MSBuild.dll
  '';
}
