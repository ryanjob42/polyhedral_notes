#!/bin/bash

PATCHELF_FOLDER="$HOME/projects/patchelf/"

# Clone the repository
git clone -b 0.17.2 git@github.com:NixOS/patchelf.git "$PATCHELF_FOLDER"

# Configure, build, and test the application.
# Note: you should look at the output of "make check" to ensure
# there were no failures.
cd "$PATCHELF_FOLDER"
./bootstrap.sh
./configure
make
make check

# Copy the executable to your "~/bin" folder.
mkdir -p "$HOME/bin/"
cp "$PATCHELF_FOLDER/src/patchelf" "$HOME/bin/batchelf"
