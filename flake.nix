{
  description = "Packaging proprietary or binary software for nixos";
  inputs.nixpkgs.url = "nixpkgs/nixos-25.11";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; {
      aoe2fe = callPackage ./aoe2fe { };
      eduke32 = callPackage ./eduke32 { };
      jave = callPackage ./jave { };
      tpps2 = callPackage ./tpps2 { };
      ip-country = callPackage ./ip-country { };
    };
    nixosModules = {
      ip-country = import ./ip-country/module.nix;
    };
    # nix eval --raw .#readme > README.md
    readme = let
      pkgs = self.outputs.packages.x86_64-linux;
      lib = nixpkgs.lib;
      deriv2md = key: d: ''
        | ${d.name} | ${d.meta.description} | ${d.meta.homepage or ""} | ${d.meta.license.fullName} | `nix run .#${key}` |
      '';
    in
      ''
      | name | description | website | licence | run |   
      |------|-------------|---------|---------|-----|
      '' + 
      lib.strings.concatStringsSep "" (lib.attrsets.mapAttrsToList deriv2md pkgs);
  };
}
