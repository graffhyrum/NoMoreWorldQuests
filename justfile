# No More World Quests — dev workflows (Mechanic + Changesets)
# Run `just --list` for all recipes.

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

addon := "NoMoreWorldQuests"
root := justfile_directory()
root_json := replace(root, "\\", "/")
# PowerShell-safe JSON (no spaces; path comes from ~/.mechanic/config.json)
mech_json := '{\""addon\"":\""' + addon + '\""}'
mech_json_coverage := '{\""addon\"":\""' + addon + '\"",\""coverage\"":true}'

export NMWQ_ROOT := root_json

default:
    @just --list

# Junction Mechanic repo clone to AddOns/Mechanic (sandbox APIDefs). Example:
#   just link-mechanic C:/src/Mechanic
link-mechanic MECHANIC_REPO:
    $target = (Resolve-Path '{{MECHANIC_REPO}}').Path; $addonsDir = Split-Path '{{root}}' -Parent; $link = Join-Path $addonsDir 'Mechanic'; if (Test-Path $link) { Remove-Item $link -Force -Recurse -ErrorAction SilentlyContinue }; New-Item -ItemType Junction -Path $link -Target $target | Out-Null; Write-Host "Linked $link -> $target"

# First-time Mechanic + sandbox setup (requires `mech` on PATH)
bootstrap:
    @just _require-mech
    @just link-mechanic C:/Tools/Mechanic
    mech setup --skip-config
    @just restore-lua
    $fw = "C:/Tools/Mechanic/sandbox/generated/test_framework.lua"; $src = "{{root_json}}/scripts/sandbox-test-framework.lua"; New-Item -ItemType Directory -Force -Path (Split-Path $fw) | Out-Null; Copy-Item $src $fw -Force

# mech setup can overwrite lua.exe with a bad SourceForge download (HTML, checksum fail)
restore-lua:
    & "{{root_json}}/scripts/restore-mechanic-lua.ps1"
    mech call sandbox.generate
    mech call addon.sync '{{mech_json}}'
    mech call env.status
    mech call tools.status

_require-mech:
    if (-not (Get-Command mech -ErrorAction SilentlyContinue)) { throw "mech not found. pip install -e C:/Tools/Mechanic/desktop" }

# Toolchain + addon health
check: validate lint

validate:
    @just _require-mech
    mech call addon.validate '{{mech_json}}'

lint:
    @just _require-mech
    mech call addon.lint '{{mech_json}}'

format:
    @just _require-mech
    mech call addon.format '{{mech_json}}'

# Offline tests (sandbox ~30ms, Busted ~5s)
test: test-sandbox test-busted

test-sandbox:
    @just _require-mech
    mech call sandbox.test '{{mech_json}}'

test-busted:
    @just _require-mech
    mech call addon.test '{{mech_json}}'

test-coverage:
    @just _require-mech
    mech call addon.test '{{mech_json_coverage}}'

# Mechanic desktop dashboard (http://localhost:3100)
dashboard:
    @just _require-mech
    mech

reload:
    @just _require-mech
    mech reload

# Changesets + release
changeset:
    bun run changeset

version:
    bun run version

sync-toc:
    bun scripts/sync-toc-version.ts

# Tag and push to trigger .github/workflows/release.yml
release TAG:
    git tag {{TAG}}
    git push origin {{TAG}}

# Push v{package.json version} tag if not already on origin
publish-tag:
    bun run publish:tag

# Pre-release gate
pre-release: check test
