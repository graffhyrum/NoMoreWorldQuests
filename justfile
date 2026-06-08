set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

default:
    @just --list

# Build a local install zip under .release/ (matches .pkgmeta ship set)
zip:
    bun scripts/package-local.ts

# Alias for zip
package: zip
