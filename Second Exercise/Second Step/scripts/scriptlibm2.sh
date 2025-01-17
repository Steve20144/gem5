#!/bin/bash
 
# Directory to save results
RESULTS_DIR=/home/arch/Desktop/shared/optim/libm2
mkdir -p $RESULTS_DIR
 
# Fixed parameters
L1_DATA_SIZE="128kB"   # L1 Data Cache Size (constant)
L1_INST_SIZE="128kB"   # L1 Instruction Cache Size (constant)
L2_SIZE="4MB"         # L2 Cache Size (constant)
CACHE_LINES=(128 256)  # Cache Line Sizes to iterate
L2_ASSOCS=(8 16)    # L2 Cache Associativity values to iterate
 
# Benchmark-specific settings for speclibm
BENCHMARK="speclibm"
BINARY_PATH="spec_cpu2006/470.lbm/src"
INPUT_ARGS="20 spec_cpu2006/470.lbm/data/lbm.in 0 1 spec_cpu2006/470.lbm/data/100_100_130_cf_a.of"
CPU_CLOCK="1GHz"
 
# Iterate through all valid configurations
for CACHE_LINE in "${CACHE_LINES[@]}"; do
    for L2_ASSOC in "${L2_ASSOCS[@]}"; do
        # Output directory for this configuration
        CONFIG_DIR="$RESULTS_DIR/${BENCHMARK}_l1i${L1_INST_SIZE}_l1d${L1_DATA_SIZE}_l2${L2_SIZE}_l2assoc${L2_ASSOC}_line${CACHE_LINE}_cpu${CPU_CLOCK}L1_Larger"
        mkdir -p $CONFIG_DIR
 
        # Construct the gem5 command
        CMD="./build/ARM/gem5.opt -d $CONFIG_DIR configs/example/se.py \
        --cpu-type=MinorCPU --caches --l2cache \
        --l1d_size=${L1_DATA_SIZE} --l1i_size=${L1_INST_SIZE} \
        --l2_size=${L2_SIZE} --l1i_assoc=2 --l1d_assoc=2 \
        --l2_assoc=${L2_ASSOC} --cacheline_size=${CACHE_LINE} --cpu-clock=${CPU_CLOCK} \
        -c ${BINARY_PATH}/${BENCHMARK} \
        -o \"${INPUT_ARGS}\" -I 100000000"
 
        # Echo the command being run
        echo "Running benchmark: $BENCHMARK with L1D=${L1_DATA_SIZE}, L2=${L2_SIZE}, L2 Assoc=${L2_ASSOC}, Cache Line=${CACHE_LINE}, CPU Clock=${CPU_CLOCK}"
 
        # Execute the command
        eval $CMD
    done
done
 
echo "Benchmarking complete. Results saved to $RESULTS_DIR."
