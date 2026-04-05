{
  description = "Packaging proprietary or binary software for nixos";
  inputs.nixpkgs.url = "nixpkgs/nixos-25.11";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; {
      aoe2fe = callPackage ./aoe2fe { };
      eduke32 = callPackage ./eduke32 { };
      jave = callPackage ./jave { };
      ip-country = callPackage ./ip-country { };
    };
    nixosModules = {
      ip-country = import ./ip-country/module.nix;
    };
  };
}
