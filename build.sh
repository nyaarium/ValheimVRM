#!/bin/bash
set -e

echo "Building ValheimVRM..."

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALHEIM_INSTALL="/mnt/s/Steam/steamapps/common/Valheim"
UNIVRM_UNITY_LIBS="$ROOT/Libs"
PROJECT_DIR="$ROOT/ValheimVRM"
OUT_DLL="$PROJECT_DIR/bin/Release/net471/ValheimVRM.dll"

cd "$PROJECT_DIR"

dotnet build --configuration Release

echo "Build completed successfully!"
