#!/usr/bin/env nix-shell
#! nix-shell -i bash -p openssl

# Cribbed from NixOS manual.
openssl pkcs12 -in "$1" -passin pass:notasecret -nodes -nocerts |\
    openssl rsa -out "$2"
