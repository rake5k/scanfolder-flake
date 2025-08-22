{
  description = "ScanFolder";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      name = "ScanFolder";

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            inherit name;

            buildInputs = with pkgs; [
              # banner printing on enter
              figlet
              lolcat

              hplip
              pdfsandwich
              poppler-utils
            ];

            shellHook = ''
              figlet ${name} | lolcat --freq 0.5
            '';
          };
        }
      );
    };
}
