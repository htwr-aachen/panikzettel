#!/bin/bash

# NewCM Font Installer Script
# Downloads, extracts, and installs NewCM fonts

set -e # Exit on any error

URL="https://download.gnu.org.ua/release/newcm/newcm-7.0.4.txz"
TEMP_DIR=$(mktemp -d)
FONTS_DIR="$HOME/.fonts"
ARCHIVE_NAME="newcm-7.0.4.txz"

echo "NewCM Font Installer"
echo "===================="

# Check if required tools are available
check_dependencies() {
  echo "Checking dependencies..."

  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is not available. Installing curl..."
    apk add --no-cache curl
  fi

  if ! command -v tar >/dev/null 2>&1; then
    echo "Error: tar is not available. Please install tar."
    exit 1
  fi

  echo "✓ Dependencies satisfied"
}

# Download the font archive
download_archive() {
  echo "Downloading NewCM fonts from $URL..."
  cd "$TEMP_DIR"

  curl -L "$URL" -o "$ARCHIVE_NAME"

  echo "✓ Download completed"
}

# Extract the .txz archive
extract_archive() {
  echo "Extracting archive..."
  cd "$TEMP_DIR"

  # Extract the .txz file (tar with xz compression)
  tar -xf "$ARCHIVE_NAME"

  echo "✓ Archive extracted"
}

# Create fonts directory if it doesn't exist
prepare_fonts_dir() {
  echo "Preparing fonts directory..."
  mkdir -p "$FONTS_DIR"
  echo "✓ Fonts directory ready: $FONTS_DIR"
}

# Copy OTF files to ~/.fonts
install_fonts() {
  echo "Installing fonts..."

  # Find the extracted directory (should be newcm-*)
  EXTRACT_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "newcm-*" | head -1)

  if [ -z "$EXTRACT_DIR" ]; then
    echo "Error: Could not find extracted directory"
    exit 1
  fi

  OTF_DIR="$EXTRACT_DIR/otf"

  if [ ! -d "$OTF_DIR" ]; then
    echo "Error: OTF directory not found at $OTF_DIR"
    exit 1
  fi

  # Copy all .otf files
  if ls "$OTF_DIR"/*.otf >/dev/null 2>&1; then
    cp "$OTF_DIR"/*.otf "$FONTS_DIR/"
    FONT_COUNT=$(ls "$OTF_DIR"/*.otf 2>/dev/null | wc -l)
    echo "✓ Installed $FONT_COUNT OTF fonts to $FONTS_DIR"
  else
    echo "Warning: No .otf files found in $OTF_DIR"
  fi
}

# Check for GPG signatures
check_signatures() {
  echo "Checking for GPG signatures..."

  EXTRACT_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "newcm-*" | head -1)
  OTF_DIR="$EXTRACT_DIR/otf"

  if ls "$OTF_DIR"/*.gpg >/dev/null 2>&1; then
    echo "Found GPG signature files:"
    ls "$OTF_DIR"/*.gpg

    if command -v gpg >/dev/null 2>&1; then
      echo "Verifying signatures..."
      for sig_file in "$OTF_DIR"/*.gpg; do
        font_file="${sig_file%.gpg}"
        if [ -f "$font_file" ]; then
          echo "Verifying $(basename "$font_file")..."
          if gpg --verify "$sig_file" "$font_file" 2>/dev/null; then
            echo "✓ Valid signature for $(basename "$font_file")"
          else
            echo "⚠ Could not verify signature for $(basename "$font_file")"
          fi
        fi
      done
    else
      echo "⚠ GPG not available - cannot verify signatures"
    fi
  else
    echo "No GPG signature files found"
  fi
}

# Update font cache
update_font_cache() {
  echo "Updating font cache..."
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$FONTS_DIR"
    echo "✓ Font cache updated"
  else
    echo "Installing fontconfig for font cache management..."
    apk add --no-cache fontconfig
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f "$FONTS_DIR"
      echo "✓ Font cache updated"
    else
      echo "⚠ Could not install fontconfig - fonts installed but cache not updated"
    fi
  fi
}

# Cleanup temporary files
cleanup() {
  echo "Cleaning up..."
  rm -rf "$TEMP_DIR"
  echo "✓ Temporary files cleaned up"
}

# Main execution
main() {
  echo "Working directory: $TEMP_DIR"

  check_dependencies
  download_archive
  extract_archive
  prepare_fonts_dir
  install_fonts
  # check_signatures
  update_font_cache
  cleanup

  echo ""
  echo "Installation completed successfully!"
  echo "NewCM fonts have been installed to $FONTS_DIR"
  echo "You may need to restart applications to see the new fonts."
}

# Run the installer
main
