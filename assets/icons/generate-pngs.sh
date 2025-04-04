#!/bin/bash
#
# ThingNix Icon Generator Script
# Converts SVG icons to PNG format at multiple resolutions
#

set -e

# Define directories
ICON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${ICON_DIR}/tools"
DESKTOP_DIR="${ICON_DIR}/desktop"
OUTPUT_DIR="${ICON_DIR}/png"

# Create output directories if they don't exist
mkdir -p "${OUTPUT_DIR}/tools/16" "${OUTPUT_DIR}/tools/32" "${OUTPUT_DIR}/tools/48" "${OUTPUT_DIR}/tools/128" "${OUTPUT_DIR}/tools/256"
mkdir -p "${OUTPUT_DIR}/desktop/16" "${OUTPUT_DIR}/desktop/32" "${OUTPUT_DIR}/desktop/48" "${OUTPUT_DIR}/desktop/128" "${OUTPUT_DIR}/desktop/256"

# Check if Inkscape is installed
if ! command -v inkscape &> /dev/null; then
    echo "Inkscape is required but not installed. Please install it using your package manager."
    echo "For example: 'nix-env -iA nixpkgs.inkscape' or 'brew install inkscape'"
    exit 1
fi

# Function to convert SVG to PNG at different sizes
convert_svg_to_png() {
    local svg_file="$1"
    local output_dir="$2"
    local basename="$(basename "${svg_file}" .svg)"
    
    echo "Converting ${basename}.svg to PNGs..."
    
    # Generate different resolutions
    inkscape --export-filename="${output_dir}/16/${basename}.png" -w 16 -h 16 "${svg_file}"
    inkscape --export-filename="${output_dir}/32/${basename}.png" -w 32 -h 32 "${svg_file}"
    inkscape --export-filename="${output_dir}/48/${basename}.png" -w 48 -h 48 "${svg_file}"
    inkscape --export-filename="${output_dir}/128/${basename}.png" -w 128 -h 128 "${svg_file}"
    inkscape --export-filename="${output_dir}/256/${basename}.png" -w 256 -h 256 "${svg_file}"
    
    echo "✅ Generated PNGs for ${basename}"
}

# Convert the main ThingNix icon
if [ -f "${ICON_DIR}/thingnix-icon.svg" ]; then
    mkdir -p "${OUTPUT_DIR}/16" "${OUTPUT_DIR}/32" "${OUTPUT_DIR}/48" "${OUTPUT_DIR}/128" "${OUTPUT_DIR}/256"
    convert_svg_to_png "${ICON_DIR}/thingnix-icon.svg" "${OUTPUT_DIR}"
else
    echo "⚠️ Warning: Main ThingNix icon (thingnix-icon.svg) not found"
fi

# Convert tools icons
echo "Processing tools icons..."
for svg_file in "${TOOLS_DIR}"/*.svg; do
    if [ -f "${svg_file}" ]; then
        convert_svg_to_png "${svg_file}" "${OUTPUT_DIR}/tools"
    fi
done

# Convert desktop icons
echo "Processing desktop icons..."
for svg_file in "${DESKTOP_DIR}"/*.svg; do
    if [ -f "${svg_file}" ]; then
        convert_svg_to_png "${svg_file}" "${OUTPUT_DIR}/desktop"
    fi
done

echo "🎉 All icons converted successfully!"
echo "PNG icons are available in the ${OUTPUT_DIR} directory"
