#!/bin/bash
# Decompiles one binary with Ghidra (headless) using ExportDecompiled.java.
# Usage (Git Bash): run_decompile.sh <binary>  -> <project>/decompiled/<name>/
# Needs Ghidra 12 unpacked in tools/ghidra_12.1.4_PUBLIC and a JDK 21+ (set JAVA_HOME).
: "${JAVA_HOME:?set JAVA_HOME to a JDK 21+ folder}"
export JAVA_HOME
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BIN="$1"; N=$(basename "$BIN")
OUT="$ROOT/decompiled/$N"; mkdir -p "$OUT" "$ROOT/tools/ghidra_projects"
cmd //c "$(cygpath -w $ROOT/tools/ghidra_12.1.4_PUBLIC/support/analyzeHeadless.bat)" \
  "$(cygpath -w $ROOT/tools/ghidra_projects)" "p_$N" \
  -import "$(cygpath -w $BIN)" -overwrite \
  -scriptPath "$(cygpath -w $ROOT/tools/scripts)" \
  -postScript ExportDecompiled.java "$(cygpath -w $OUT)" \
  -analysisTimeoutPerFile 3600 > "$OUT/ghidra.log" 2>&1
grep -E "functions exported|ERROR" "$OUT/ghidra.log" | tail -3
