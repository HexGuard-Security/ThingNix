#!/usr/bin/env bash
# ThingNix Build Script
# Builds ThingNix ISO image for various architectures

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="./build"
CACHE_DIR="./cache"
VERSION="0.1.0-alpha20"  # Hardcoded version for now
DEFAULT_ARCH="x86_64-linux"
SUPPORTED_ARCHS=("x86_64-linux" "aarch64-linux")
ISO_NAME="thingnix"

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "████████╗██╗  ██╗██╗███╗   ██╗ ██████╗ ███╗   ██╗██╗██╗  ██╗"
    echo "╚══██╔══╝██║  ██║██║████╗  ██║██╔════╝ ████╗  ██║██║╚██╗██╔╝"
    echo "   ██║   ███████║██║██╔██╗ ██║██║  ███╗██╔██╗ ██║██║ ╚███╔╝ "
    echo "   ██║   ██╔══██║██║██║╚██╗██║██║   ██║██║╚██╗██║██║ ██╔██╗ "
    echo "   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝██║ ╚████║██║██╔╝ ██╗"
    echo "   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝"
    echo "                                                             "
    echo -e "   IoT Penetration Testing & Hardware Hacking OS v${VERSION}${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check for Nix
    if ! command -v nix >/dev/null 2>&1; then
        echo -e "${RED}Error: Nix is not installed. Please install Nix first:${NC}"
        echo "  curl -L https://nixos.org/nix/install | sh"
        exit 1
    fi
    
    # Check for Nix Flakes
    if ! nix --version | grep -q "nix.*2."; then
        echo -e "${YELLOW}Warning: You might be running an older version of Nix.${NC}"
        echo "Flakes might not be available. Consider updating Nix."
    fi
    
    # Make sure flakes are enabled
    if ! nix show-config | grep -q "experimental-features.*flakes"; then
        echo -e "${YELLOW}Warning: Nix Flakes might not be enabled.${NC}"
        echo "Consider adding the following to your nix.conf:"
        echo "  experimental-features = nix-command flakes"
    fi
    
    # Check for nixos-generators
    if ! nix-shell -p nixos-generators --run "which nixos-generate" >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: nixos-generators not directly available.${NC}"
        echo "The script will use it via Nix directly."
    fi
    
    echo -e "${GREEN}Prerequisites check completed.${NC}"
}

# Create build directories
create_build_dirs() {
    echo -e "${BLUE}Creating build directories...${NC}"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$CACHE_DIR"
    echo -e "${GREEN}Build directories created.${NC}"
}

# Build ThingNix ISO
build_iso() {
    local arch=$1
    local output_name="${ISO_NAME}-${VERSION}-${arch//-/_}"
    
    echo -e "${BLUE}Building ThingNix ISO for ${arch}...${NC}"
    echo "This might take a while. Go grab a coffee! ☕"
    
    # Build the ISO using Nix
    NIXPKGS_ALLOW_UNFREE=1 nix build \
        --option substituters "https://cache.nixos.org https://nix-community.cachix.org" \
        --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" \
        ".#packages.${arch}.iso" \
        --out-link "$BUILD_DIR/$output_name.drv"
    
    # Copy the result to the build directory
    cp -f $(readlink -f "$BUILD_DIR/$output_name.drv") "$BUILD_DIR/$output_name.iso"
    
    echo -e "${GREEN}Successfully built ISO for ${arch}!${NC}"
    echo "ISO available at: $BUILD_DIR/$output_name.iso"
}

# Clean build artifacts
clean_build() {
    echo -e "${BLUE}Cleaning build artifacts...${NC}"
    rm -rf "$BUILD_DIR"
    echo -e "${GREEN}Build artifacts cleaned.${NC}"
}

# Create checksums for built ISOs
create_checksums() {
    echo -e "${BLUE}Creating checksums for ISOs...${NC}"
    cd "$BUILD_DIR" || exit
    sha256sum *.iso > SHA256SUMS
    cd - > /dev/null || exit
    echo -e "${GREEN}Checksums created at $BUILD_DIR/SHA256SUMS${NC}"
}

# Show help message
show_help() {
    echo "ThingNix Build Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -a, --arch ARCH     Build for specific architecture (default: $DEFAULT_ARCH)"
    echo "                      Supported: ${SUPPORTED_ARCHS[*]}"
    echo "  -c, --clean         Clean build artifacts before building"
    echo "  -h, --help          Show this help message"
    echo "  -v, --verbose       Enable verbose output"
    echo ""
    echo "Examples:"
    echo "  $0                  Build for $DEFAULT_ARCH"
    echo "  $0 -a aarch64-linux Build for aarch64-linux"
    echo "  $0 -c               Clean and build for $DEFAULT_ARCH"
}

# Main function
main() {
    local arch="$DEFAULT_ARCH"
    local clean_first=false
    local verbose=false
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -a|--arch)
                arch="$2"
                shift 2
                ;;
            -c|--clean)
                clean_first=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate architecture
    if [[ ! " ${SUPPORTED_ARCHS[*]} " =~ " ${arch} " ]]; then
        echo -e "${RED}Error: Unsupported architecture: ${arch}${NC}"
        echo "Supported architectures: ${SUPPORTED_ARCHS[*]}"
        exit 1
    fi
    
    # Set verbose mode if requested
    if $verbose; then
        set -x
    fi
    
    print_banner
    check_prerequisites
    
    if $clean_first; then
        clean_build
    fi
    
    create_build_dirs
    build_iso "$arch"
    create_checksums
    
    echo -e "${GREEN}ThingNix build completed successfully!${NC}"
    echo "ISO is available at: $BUILD_DIR/${ISO_NAME}-${VERSION}-${arch//-/_}.iso"
    echo "Checksum available at: $BUILD_DIR/SHA256SUMS"
}

# Run main function
main "$@"
