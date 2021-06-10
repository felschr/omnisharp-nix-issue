let sources = import ./nix/sources.nix;

in { pkgs ? import sources.nixpkgs { } }:

with pkgs;
with lib;

let
  dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_5_0 ];
  dotnetRoot = "${dotnet-combined}";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/bin/dotnet";

  omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
    pname = "omnisharp-roslyn";
    version = "1.37.10";

    src = pkgs.fetchurl {
      url =
        "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
      sha256 = "0wrkw04yw0lx8w7gwwbiz0pdh2qcqmmdh5wmf0d9v0nxib18dxrs";
    };

    installPhase = ''
      mkdir -p $out/bin
      cd ..
      cp -r src $out/

      rm -r $out/src/.msbuild
      mkdir $out/src/.msbuild
      ln -s ${pkgs.msbuild}/lib/mono/xbuild/* $out/src/.msbuild/
      rm $out/src/.msbuild/Current
      mkdir $out/src/.msbuild/Current
      ln -s ${pkgs.msbuild}/lib/mono/xbuild/Current/* $out/src/.msbuild/Current/
      ln -s ${pkgs.msbuild}/lib/mono/msbuild/Current/bin $out/src/.msbuild/Current/Bin

      chmod -R u+w $out/src

      makeWrapper ${pkgs.mono}/bin/mono $out/bin/omnisharp \
      --add-flags "$out/src/OmniSharp.exe"
    '';
  });

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
