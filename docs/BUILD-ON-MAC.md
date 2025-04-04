# Building ThingNix on macOS

Because ThingNix is a NixOS-based operating system, building a complete ISO requires Linux-specific components that aren't available directly on macOS. Here are the recommended approaches for building ThingNix on a Mac:

## Method 1: Using a Linux VM with UTM/QEMU (Recommended)

1. Install [UTM](https://mac.getutm.app/) on your Mac
2. Download a minimal NixOS ISO from [nixos.org](https://nixos.org/download.html)
3. Create a VM with the NixOS ISO
4. Once booted into NixOS, clone the ThingNix repository:
   ```bash
   nix-shell -p git
   git clone https://github.com/HexGuard-Security/ThingNix.git
   cd ThingNix
   ```
5. Build the ThingNix ISO:
   ```bash
   ./build.sh
   ```
6. Copy the resulting ISO back to your Mac using SCP, a shared folder, or other file transfer methods

## Method 2: Using Docker/Podman

1. Install Docker for Mac
2. Create a file named `Dockerfile` with the following content:
   ```Dockerfile
   FROM nixos/nix
   
   RUN nix-channel --update
   WORKDIR /build
   
   # Install git
   RUN nix-env -iA nixpkgs.git
   
   # Clone the ThingNix repository
   RUN git clone https://github.com/HexGuard-Security/ThingNix.git
   WORKDIR /build/ThingNix
   
   # Set up Nix with flakes
   RUN mkdir -p ~/.config/nix && \
       echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
   
   # The build command would be run interactively
   CMD ["/bin/sh"]
   ```

3. Build and run the Docker container:
   ```bash
   docker build -t thingnix-builder .
   docker run -it --privileged -v $PWD/output:/output thingnix-builder
   ```

4. Inside the container, run:
   ```bash
   ./build.sh
   cp build/*.iso /output/
   ```

## Method 3: Using a Remote Linux Server

If you have access to a Linux server or cloud instance:

1. Set up NixOS on a remote Linux server or cloud instance (AWS, DigitalOcean, etc.)
2. Clone the ThingNix repository and build there
3. Download the resulting ISO to your Mac

## Testing the ISO

Once you have built the ISO, you can test it using UTM/QEMU on your Mac:

1. Create a new VM in UTM
2. Use the ThingNix ISO as the boot device
3. Allocate at least 4GB RAM and 2 CPU cores
4. Boot the VM to test the ThingNix environment

## Building for Different Architectures

For x86_64 (Intel/AMD):
```bash
./build.sh --arch x86_64-linux
```

For aarch64 (ARM64):
```bash
./build.sh --arch aarch64-linux
```

Note that building for architectures different from your host may require additional setup or emulation layers.
