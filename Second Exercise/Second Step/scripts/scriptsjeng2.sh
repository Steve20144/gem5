#!/bin/bash
 
# Directory to save results
RESULTS_DIR=/home/arch/Desktop/shared/optim/sjeng2/new/L1
mkdir -p $RESULTS_DIR
 
# Fixed cache sizes
L1_DATA_SIZE="128kB"  # L1 Data Cache Size (constant)
L2_SIZE="4MB"        # L2 Cache Size (constant)
 
# Associativity values to test
L1_INST_ASSOC=2 # L1 Instruction Cache Associativity (constant)
L1_DATA_ASSOC=2 # L1 Data Cache Associativity (constant)
L2_ASSOCS=(8 16)      # L2 Cache Associativity
 
# Cache parameter values
L1_INST_SIZE="32kB" # L1 Instruction Cache Sizes to iterate (constant)
CACHE_LINES=128          # Cache Line Sizes
 
# Benchmark-specific settings for specsjeng
BENCHMARK="specsjeng"
BINARY_PATH="spec_cpu2006/458.sjeng/src"
INPUT_ARGS="spec_cpu2006/458.sjeng/data/test.txt"
CPU_CLOCK="1GHz"
 
# Iterate through all valid configurations
            for L2_ASSOC in "${L2_ASSOCS[@]}"; do
                 # Output directory for this configuration
                    CONFIG_DIR="$RESULTS_DIR/${BENCHMARK}_l1i${L1_INST_SIZE}_l1iassoc${L1_INST_ASSOC}_l1d${L1_DATA_SIZE}_l1dassoc${L1_DATA_ASSOC}_l2${L2_SIZE}_l2assoc${L2_ASSOC}_line${CACHE_LINE}_cpu${CPU_CLOCK}_new_256cacheline"
                    mkdir -p $CONFIG_DIR
 
                    # Construct the gem5 command
                    CMD="./build/ARM/gem5.opt -d $CONFIG_DIR configs/example/se.py \
                    --cpu-type=MinorCPU --caches --l2cache \
                    --l1d_size=${L1_DATA_SIZE} --l1i_size=${L1_INST_SIZE} \
                    --l2_size=${L2_SIZE} --l1i_assoc=${L1_INST_ASSOC} \
                    --l1d_assoc=${L1_DATA_ASSOC} --l2_assoc=${L2_ASSOC} \
                    --cacheline_size=${CACHE_LINES} --cpu-clock=${CPU_CLOCK} \
                    -c ${BINARY_PATH}/${BENCHMARK} \
                    -o \"${INPUT_ARGS}\" -I 100000000"
 
                    # Echo the command being run
                    echo "Running benchmark: $BENCHMARK with L1I=${L1_INST_SIZE}, L1D=${L1_DATA_SIZE}, L2=${L2_SIZE}, CPU Clock=${CPU_CLOCK}, L1I Assoc=${L1_INST_ASSOC}, L1D Assoc=${L1_DATA_ASSOC}, L2 Assoc=${L2_ASSOC}"
 
                    # Execute the command
                    eval $CMD
                done
echo "Benchmarking complete. Results saved to $RESULTS_DIR."
