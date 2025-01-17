#!/bin/bash
 
# Directory to save results
RESULTS_DIR=/home/arch/Desktop/shared/optim/sjeng
mkdir -p $RESULTS_DIR
 
# Fixed associativity values
L1_INST_ASSOC=2        # L1 Instruction Cache Associativity
L1_DATA_ASSOC=2        # L1 Data Cache Associativity
L2_ASSOC=4             # L2 Cache Associativity
 
# Cache parameter values
L1_INST_SIZES=("32kB" "64kB") # L1 Instruction Cache Size
L1_DATA_SIZES=("64kB" "128kB") # L1 Data Cache Size
L2_SIZES=("2MB" "4MB")        # L2 Cache Size
CACHE_LINES=(64 128)          # Cache Line Size
 
# Benchmark-specific settings for specsjeng
BENCHMARK="specsjeng"
BINARY_PATH="spec_cpu2006/458.sjeng/src"
INPUT_ARGS="spec_cpu2006/458.sjeng/data/test.txt"
CPU_CLOCK="1GHz"
 
# Iterate through all valid configurations
for L1_INST_SIZE in "${L1_INST_SIZES[@]}"; do
    for L1_DATA_SIZE in "${L1_DATA_SIZES[@]}"; do
        for L2_SIZE in "${L2_SIZES[@]}"; do
            for CACHE_LINE in "${CACHE_LINES[@]}"; do
                # Ensure total L1 cache size does not exceed 256KB
                TOTAL_L1_SIZE=$(( $(echo $L1_INST_SIZE | sed 's/kB//') + $(echo $L1_DATA_SIZE | sed 's/kB//') ))
                if (( TOTAL_L1_SIZE > 256 )); then
                    continue
                fi
 
                # Ensure L2 cache size does not exceed 4MB
                if [[ $L2_SIZE == "4MB" ]]; then
                    if (( $(echo $L2_SIZE | sed 's/MB//') > 4 )); then
                        continue
                    fi
                fi
 
                # Output directory for this configuration
                CONFIG_DIR="$RESULTS_DIR/${BENCHMARK}_l1i${L1_INST_SIZE}_l1iassoc${L1_INST_ASSOC}_l1d${L1_DATA_SIZE}_l1dassoc${L1_DATA_ASSOC}_l2${L2_SIZE}_l2assoc${L2_ASSOC}_line${CACHE_LINE}_cpu${CPU_CLOCK}"
                mkdir -p $CONFIG_DIR
 
                # Construct the gem5 command
                CMD="./build/ARM/gem5.opt -d $CONFIG_DIR configs/example/se.py \
                --cpu-type=MinorCPU --caches --l2cache \
                --l1d_size=${L1_DATA_SIZE} --l1i_size=${L1_INST_SIZE} \
                --l2_size=${L2_SIZE} --l1i_assoc=${L1_INST_ASSOC} \
                --l1d_assoc=${L1_DATA_ASSOC} --l2_assoc=${L2_ASSOC} \
                --cacheline_size=${CACHE_LINE} --cpu-clock=${CPU_CLOCK} \
                -c ${BINARY_PATH}/${BENCHMARK} \
                -o \"${INPUT_ARGS}\" -I 100000000"
 
                # Echo the command being run
                echo "Running benchmark: $BENCHMARK with L1I=${L1_INST_SIZE}, L1D=${L1_DATA_SIZE}, L2=${L2_SIZE}, CPU Clock=${CPU_CLOCK}"
 
                # Execute the command
                eval $CMD
            done
        done
    done
done
 
echo "Benchmarking complete. Results saved to $RESULTS_DIR."
