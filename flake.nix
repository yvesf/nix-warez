{
  description = "Packaging proprietary or binary software for nixos";
  inputs.nixpkgs.url = "nixpkgs/nixos-20.09";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; {
      privateTax2019 = callPackage (import ./privateTax { version = "2019"; sha256 = "sha256-mbr+GjYBcRuI7eL9qrwCMhv8UqBKwejTUJhnZq7wXyI="; }) {};
      privateTax2020 = callPackage (import ./privateTax { version = "2020"; sha256 = "sha256-lwL/ScG4JJR6YMA/QAgypeB61QSiSA2AJU9chjUZ8Fg="; }) {};
      tinygo-bin = callPackage ./tinygo-bin {};
      eduke32 = callPackage ./eduke32 {};
      jave = callPackage ./jave {};
    };
  };
}
