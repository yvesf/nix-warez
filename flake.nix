{
  description = "Packaging proprietary or binary software for nixos";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; {
      aoe2fe = callPackage ./aoe2fe {};
      eduke32 = callPackage ./eduke32 {};
      jave = callPackage ./jave {};
      privateTax2019 = callPackage (import ./privateTax { version = "2019"; sha256 = "sha256-mbr+GjYBcRuI7eL9qrwCMhv8UqBKwejTUJhnZq7wXyI="; }) {};
      privateTax2020 = callPackage (import ./privateTax { 
        version = "2020"; 
        # sha256 = "sha256-lwL/ScG4JJR6YMA/QAgypeB61QSiSA2AJU9chjUZ8Fg="; outdated 2021-04-21
        sha256 = "sha256-y2o4wMO2JJKXdnOB9Jx+4N7SkAdBffop1159hQ+YNMc=";
      }) {};
      qelectrotech = callPackage ./qelectrotech {};
      tinygo-bin = callPackage ./tinygo-bin {};
      rir-ip = callPackage ./rir-ip {};
    };
    nixosModules = {
      tpLightBell = import ./tpLightBell/module.nix;
    };
  };
}
