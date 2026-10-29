OUTPUT_DIRECTORY=data/$(hostname)_$(date +%F)
mkdir -p "$OUTPUT_DIRECTORY"
OUTPUT_FILE=$OUTPUT_DIRECTORY/measurements_$(date +%R).txt

touch "$OUTPUT_FILE"

#Make a sizes array in order to better manipulate them.
sizes=(100 1000 10000 50000) # 100000 500000 1000000 5000000

#Make an array that contains all the sizes randomly shuffled,
#to prevent bias from throttling.

reps=$1
all_runs=()

for size in "${sizes[@]}"; do
    for ((r = 0; r < reps; r++)); do
        all_runs+=("$size")
    done
done

#Run loop for all sizes (that exist reps times).
for i in $(printf "%s\n" "${all_runs[@]}" | shuf); do
    echo "Size: $i" >>"$OUTPUT_FILE"
    ./../bin/quicksort "$i" >>"$OUTPUT_FILE"
done
