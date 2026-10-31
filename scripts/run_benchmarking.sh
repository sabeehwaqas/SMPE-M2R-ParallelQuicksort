#!/bin/bash

reps=${1:?"Usage: $0 <iterations>"}

# Resolve paths relative to this script, so it works from any directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Output goes in <repo>/data (one folder above scripts/), not scripts/data.
OUTPUT_DIRECTORY="$ROOT_DIR/data/$(hostname)_$(date +%F)"
mkdir -p "$OUTPUT_DIRECTORY"

# Same minute => unique file (never append): add a counter before the _<reps>it suffix.
base="$OUTPUT_DIRECTORY/measurements_$(date +%R)"
OUTPUT_FILE="${base}_${reps}it.txt"
n=2
while [ -e "$OUTPUT_FILE" ]; do
    OUTPUT_FILE="${base}_${n}_${reps}it.txt"
    n=$((n + 1))
done

touch "$OUTPUT_FILE"

{
    echo "====="
    case "$(uname -s)" in
    Linux*)
        lscpu | grep "Model name" | sed 's/^[ \t]*//'
        free -h | awk 'NR==2{print "RAM: " $2}'
        echo "Threads: $(nproc)"
        ;;
    Darwin*)
        sysctl -n machdep.cpu.brand_string
        echo "RAM: $(($(sysctl -n hw.memsize) / 1024 ** 3)) GB"
        echo "Threads: $(sysctl -n hw.logicalcpu)"
        ;;
    *MINGW* | *MSYS* | *CYGWIN*) powershell.exe -Command "(Get-CimInstance Win32_Processor).Name; 'RAM: ' + [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,2).ToString() + ' GB'; 'Threads: ' + (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors" | tr -d '\r' ;;
    esac
    echo "====="
} >>"$OUTPUT_FILE"

#Make a sizes array in order to better manipulate them.
sizes=(100 1000 10000 50000) # 100000 500000 1000000 5000000

#Make an array that contains all the sizes randomly shuffled,
#to prevent bias from throttling.

all_runs=()

for size in "${sizes[@]}"; do
    for ((r = 0; r < reps; r++)); do
        all_runs+=("$size")
    done
done

#Run loop for all sizes (that exist reps times).
for i in $(printf "%s\n" "${all_runs[@]}" | shuf); do
    echo "Size: $i" >>"$OUTPUT_FILE"
    "$ROOT_DIR/bin/quicksort" "$i" >>"$OUTPUT_FILE"
done