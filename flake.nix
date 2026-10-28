{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";

    # Version of osprey-framework the shell installs; "" tracks latest
    ospreyVersion = "2026.6.2";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) ["claude-code"];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        claude-code
        git
        nodejs
        uv
        python312
      ];

      UV_PYTHON = "${pkgs.python312}/bin/python3";
      UV_PYTHON_DOWNLOADS = "never";

      # Prebuilt PyPI wheels expect these system libs.
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib pkgs.zlib];

      shellHook = ''
        # Keep uv tools local to this project so they don't leak into `~/.local`,
        # anchored to the repo root so entering from a subdirectory reuses one install
        uvRoot="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
        export UV_TOOL_DIR="$uvRoot/.uv/tools"
        export UV_TOOL_BIN_DIR="$uvRoot/.uv/bin"
        export PATH="$UV_TOOL_BIN_DIR:$PATH"

        ospreyWant="${ospreyVersion}"
        ospreyHave=""
        if [ -x "$UV_TOOL_BIN_DIR/osprey" ]; then
          ospreyHave="$("$UV_TOOL_BIN_DIR/osprey" --version 2>/dev/null | awk '{print $NF}')"
        fi

        # Install once, then only when the pinned version stops matching what's there

        # If not installed at all
        if [ -z "$ospreyHave" ]; then
          uv tool install "osprey-framework''${ospreyWant:+==$ospreyWant}"
        # If versions are out of sync
        elif [ -n "$ospreyWant" ] && [ "$ospreyHave" != "$ospreyWant" ]; then
          echo "osprey $ospreyHave installed, desired $ospreyWant; reinstalling" >&2
          uv tool install --force "osprey-framework==$ospreyWant"
        fi
        unset ospreyWant ospreyHave
      '';
    };
  };
}
