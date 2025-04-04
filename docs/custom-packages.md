# Adding Custom Packages to ThingNix

This guide explains how to add custom packages to ThingNix that aren't already included in the distribution or in the nixpkgs repository.

## Table of Contents
- [Understanding Nix Packages](#understanding-nix-packages)
- [Adding a Simple Package](#adding-a-simple-package)
- [Creating a Package from GitHub](#creating-a-package-from-github)
- [Integrating with ThingNix](#integrating-with-thingnix)
- [Testing Your Package](#testing-your-package)
- [Troubleshooting](#troubleshooting)

## Understanding Nix Packages

In NixOS, packages are defined using the Nix language. A package definition typically includes:

- Source location (URL, Git repository, etc.)
- Build instructions
- Dependencies
- Metadata (description, license, etc.)

ThingNix provides a structured way to add custom packages that aren't in the main nixpkgs repository.

## Adding a Simple Package

### 1. Create a Package Directory

First, create a new file in the `nixos/packages` directory:

```bash
mkdir -p nixos/packages
touch nixos/packages/my-tool.nix
```

### 2. Define the Package

Edit the file with a basic package definition:

```nix
{ lib, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "username";
    repo = "my-tool";
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
    # Replace with actual hash from `nix-prefetch-git`
  };

  # Build dependencies
  buildInputs = [ 
    # Add dependencies here
  ];

  # Installation
  installPhase = ''
    mkdir -p $out/bin
    cp my-tool $out/bin/
    chmod +x $out/bin/my-tool
  '';

  meta = with lib; {
    description = "My custom security tool";
    homepage = "https://github.com/username/my-tool";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ your-name ];
  };
}
```

### 3. Getting the SHA256 Hash

To get the correct SHA256 hash for the source:

```bash
nix-prefetch-git --url https://github.com/username/my-tool --rev v1.0.0
```

Replace the placeholder hash with the output from this command.

## Creating a Package from GitHub

For many tools, the process is straightforward:

### Example: Python Tool

```nix
{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "security-tool";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "security";
    repo = "security-tool";
    rev = "v${version}";
    sha256 = "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    pycrypto
  ];

  # Skip tests if they're problematic
  doCheck = false;

  meta = with lib; {
    description = "A security analysis tool";
    homepage = "https://github.com/security/security-tool";
    license = licenses.bsd3;
    maintainers = [ maintainers.your-name ];
  };
}
```

### Example: C/C++ Tool

```nix
{ lib, stdenv, fetchFromGitHub, cmake, libusb1, pkg-config }:

stdenv.mkDerivation rec {
  pname = "hardware-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "hardware";
    repo = "hardware-tool";
    rev = "v${version}";
    sha256 = "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libusb1 ];

  meta = with lib; {
    description = "A hardware analysis utility";
    homepage = "https://github.com/hardware/hardware-tool";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.your-name ];
  };
}
```

## Integrating with ThingNix

After creating your package definition, you need to include it in ThingNix:

### 1. Create an Overlay

Edit the overlay in the appropriate module file, e.g., `nixos/modules/security-tools.nix`:

```nix
nixpkgs.overlays = [
  (final: prev: {
    # Existing overlays...
    my-tool = final.callPackage ../packages/my-tool.nix {};
  })
];
```

### 2. Add to System Packages

In the same file, add your package to the installed packages:

```nix
environment.systemPackages = with pkgs; [
  # Existing packages...
  my-tool
];
```

## Testing Your Package

Before integrating into the main build, you can test your package:

```bash
# Build the package separately
nix-build -E 'with import <nixpkgs> {}; callPackage ./nixos/packages/my-tool.nix {}'

# If successful, this creates a result/ directory with your built package
./result/bin/my-tool --help
```

## Troubleshooting

### Common Issues

1. **SHA256 Mismatch**: If the source changes, the hash will need to be updated. Re-run `nix-prefetch-git`.

2. **Build Failures**: Check build logs for missing dependencies or compile errors. Add necessary dependencies to `buildInputs`.

3. **Runtime Issues**: If the package builds but doesn't run properly, you may need to wrap the binary with required environment variables:

```nix
makeWrapper = true;

postFixup = ''
  wrapProgram $out/bin/my-tool \
    --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ dependency1 dependency2 ]}" \
    --prefix PATH : "${lib.makeBinPath [ dependency3 dependency4 ]}"
'';
```

### Getting Help

If you're stuck, you can:

1. Check existing package definitions in nixpkgs for similar software
2. Look at the upstream build instructions (Makefiles, CMakeLists.txt, etc.)
3. Ask in the ThingNix community for assistance

## Advanced Package Examples

The `nixos/packages/examples/` directory contains example package definitions for:

- GUI applications
- Drivers and firmware
- Security tools with complex dependencies
- Python applications
- Rust applications

These can serve as templates for your own package definitions.

## Contributing Packages Back

If you create a package that might be useful for others:

1. Ensure it builds reliably
2. Add good documentation
3. Submit a PR to the ThingNix repository
4. Consider submitting to nixpkgs for even wider distribution
