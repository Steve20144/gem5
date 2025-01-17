

---

# gem5 Report

**Author:** Stefanos Fragoulis  
**Date:** January 2025

---

## Table of Contents

1. [Introduction & Preface](#introduction--preface)
    - [Environment Setup](#environment-setup)
2. [Exercises](#exercises)
    - [First Exercise](#first-exercise)
        - [First Question](#first-question)
        - [Second Question](#second-question)
        - [Some information on different CPU models.](#some-information-on-different-cpu-models)
    - [Second Exercise](#second-exercise)
    - [Third Exercise](#third-exercise)

---

## Introduction & Preface



gem5 is an open-source, modular simulation platform widely used in computer architecture research and development. It allows researchers and engineers to model and analyze the behavior of computer systems, including CPUs, memory hierarchies, caches, and interconnects. By providing a flexible and extensible framework, gem5 supports multiple processor architectures such as x86, ARM, and RISC-V, as well as various system configurations.

The platform is instrumental for performance analysis, enabling the evaluation and optimization of both hardware components and software applications. It serves as a valuable tool for research and development, allowing experimentation with new architectural features, memory systems, and caching strategies. Additionally, gem5 is utilized for educational purposes, helping students and professionals understand the intricacies of computer architecture and system design. By combining different simulation techniques, including cycle-accurate and system-level modeling, gem5 offers detailed insights into the interactions between hardware and software. Its versatility and comprehensive capabilities make gem5 an essential tool for advancing computer architecture innovations and optimizing system performance.

gem5 was originally conceived for computer architecture research in academia, but it has grown to be used in computer system design by academia, industry for research, and in teaching.

The purpose of this project was to familiarize the students with the gem5 tool, as it is one of the most widely-used tools in the field of Computer Architecture.

### Environment Setup



For this project, a Virtual Machine with gem5 installed was utilized to avoid unnecessary installation and dependency issues. The VM was provided by the assignment PDF and was executed on VirtualBox with 12 processors and 16GB of RAM.

## Exercises


The first exercise aims at setting the foundations for understanding the functionality and operation of the gem5 simulation tool. This includes an initial read of the gem5 documentation, a fundamental exploration of the various CPU models, and an evaluation of the significance of the `stats.txt` file in performance analysis. Moreover, the exercise encourages students to experiment with different memory configurations, CPU architectures, and diverse CPU frequencies to gain practical insights into their impact on system behavior and performance.

### First Exercise

#### First Question

**"Open the `starter_se.py` that was utilized in the prior "Hello World" example and try to understand the basic parameters that gem5 uses regarding the emulated system. Write down basic system characteristics such as CPU type, operation frequency, basic units, caches, memory, etc."**

- **CPU Type:**  
  The script uses a dictionary `cpu_types` alongside a `--cpu` argument. The `cpu_types` dictionary is the following:

  ```python
  cpu_types = {
      "atomic": (AtomicSimpleCPU, None, None, None, None),
      "minor": (MinorCPU,
                devices.L1I, devices.L1D,
                devices.WalkCache,
                devices.L2),
      "hpi": (HPI.HPI,
              HPI.HPI_ICache, HPI.HPI_DCache,
              HPI.HPI_WalkCache,
              HPI.HPI_L2)
  }
  ```

  It is clear that it involves three different CPU models, some of which will be further discussed later. The desired CPU type can be set by including a `--cpu` argument in the bash command. For example:

  ```bash
  /build/ARM/gem5.opt -d hello_result configs/example/arm/starter_se.py --cpu="minor" "tests/test-progs/hello/bin/arm/linux/hello"
  ```

  In this provided example, the desired CPU type is Minor.

- **Caches:**  
  Caches are part of the `cpu_types` configuration. In the "Hello World" example, caches are added as follows:

  ```python
  if self.cpu_cluster.memoryMode() == "timing":
      self.cpu_cluster.addL1()
      self.cpu_cluster.addL2(self.cpu_cluster.clk_domain)
  ```

- **Basic Units:**  
  Defined inside the `SimpleSeSystem` class as follows:

  ```python
  self.voltage_domain = VoltageDomain(voltage="3.3V")
  self.clk_domain = SrcClockDomain(clock="1GHz",
                                   voltage_domain=self.voltage_domain)
  ```

- **CPU Frequency:**  
  Defined by the `--cpu-freq` argument, as this line dictates:

  ```python
  parser.add_argument("--cpu-freq", type=str, default="1GHz")
  ```

  In our example, the default 1GHz frequency was kept, as no `--cpu-freq` argument was used.

- **Memory Type:**  
  Specified by the `--mem-type` argument, as the following line dictates:

  ```python
  parser.add_argument("--mem-type", default="DDR3_1600_8x8",
                      choices=ObjectList.mem_list.get_names(),
                      help="type of memory to use")
  ```

  And the memory configuration is applied in this line:

  ```python
  MemConfig.config_mem(args, system)
  ```

  In the "Hello World" example, the default value was kept.

#### Second Question


**"Besides the output file `stats.txt` generated at the end of the simulation, gem5 also produces `config.ini` and `config.json` files that provide information about the simulated system. 
a. Use these files to verify your answer to the first question by including the relevant fields. 
b. What are `sim_seconds`, `sim_insts`, and `host_inst_rate`?
c. What is the total number of committed instructions, and why does this number differ from the statistics presented by gem5?
d. How many times was the L2 cache accessed, and how could you calculate these accesses if they were not provided by the simulator?"**

Using the **`config.ini`**, the above information can be verified as follows:

- **CPU Type:**

  ```ini
  [system.cpu_cluster.cpus]
  type=MinorCPU
  ```

- **Cache Configuration:**

  ```ini
  [system.cpu_cluster.cpus.icache]
  type=Cache
  children=replacement_policy tags
  addr_ranges=0:18446744073709551615
  assoc=3
  ```

- **Memory Controller Configuration:**
  
  The `[system]` section includes a `memory` attribute which points to the following sections:

  ```ini
  [system.mem_ctrls0]
  type=DRAMCtrl

  [system.mem_ctrls1]
  type=DRAMCtrl
  ```

- **Operating Frequency:**

  ```ini
  [system.clk_domain]
  type=SrcClockDomain
  clock=1000
  ```

Using the **`config.json`**, the above information can be verified as follows:

- **CPU Type:**

  ```json
  "system": {
      "cpu_cluster": {
          "cpus": [
              {
                  "cxx_class": "MinorCPU"
              }
          ]
      }
  }
  ```

- **Cache Configuration:**

  ```json
  "system": {
      "cpu_cluster": {
          "cpus": [
              {
                  "icache": {
                      "type": "Cache"
                  }
              }
          ]
      }
  }
  ```

- **Operating Frequency:**

  ```json
  "clk_domain": {
      "name": "clk_domain",
      "clock": [
          1000
      ],
  }
  ```

- **Memory Configuration:**

  ```json
  "membus": {
      "point_of_coherency": true,
      "system": "system",
      "response_latency": 2,
      "cxx_class": "CoherentXBar",
      "max_routing_table_size": 512,
      "forward_latency": 4,
      "clk_domain": "system.clk_domain",
      "max_outstanding_snoops": 512,
      "point_of_unification": true,
      "width": 16,
  }
  ```

Additional Metrics:

- **sim_seconds:** Represents the real time that was simulated by gem5.
- **sim_inst:** Represents the number of instructions that were executed in total from the simulated system during the simulation.
- **host_inst_rate:** Measures the simulation speed in terms of instructions per second executed by the simulated system on the host computer.

The total number of **committed instructions** can be found inside the `stats.txt` file under:

```plaintext
system.cpu_cluster.cpus.committedInsts
```

and is equal to **5027**.

This number differs from fields like **Committed ops**, which is equal to **5831**:

- **3789 int ALU**
- **1085 memread**
- **4 int mult**
- **3 cmdfloatmisc**
- **950 memwrite**

The L2 cache total data accesses can be found inside the `stats.txt` file from:

```plaintext
system.cpu_cluster.l2.overall_accesses::total          474
```

where the total **L2 accesses** are 474.

In the case where said statistic was not provided, the total L2 accesses could be calculated through other statistics such as:

```plaintext
system.cpu_cluster.cpus.dcache.overall_misses::total          177
system.cpu_cluster.cpus.icache.overall_misses::total          327
```

By adding those numbers, the number 504 comes up. However, there is another interesting statistic:

```plaintext
system.cpu_cluster.cpus.dcache.overall_mshr_hits::.cpu_cluster.cpus.data           30
```

which clarifies the reason why 504 came up. The MSHR (Miss Status Holding Register) is used in cache hierarchies to track outstanding memory requests (**cache misses**) that are in progress. When a new cache request arrives and matches an ongoing MSHR entry, it is considered an **MSHR Hit**. Thus, MSHR hits **do not generate new L2 accesses** because the L1 cache reuses the same outstanding request already being processed.

If 30 is subtracted from 504, the number that comes up (474) matches the total L2 accesses.

##### Some Information on Different CPU Models

The gem5 simulator offers various **in-order CPU models**, each with specific characteristics and use cases:

- **SimpleCPU:**  
  A basic, functional in-order CPU model, suitable for scenarios where detailed simulation is not required. It is usually used for the initial phase of program development. It is divided into three subcategories:
  - **AtomicSimpleCPU:** Focuses on simplicity and speed.
  - **TimingSimpleCPU:** Offers more realistic simulation of memory delays.

- **MinorCPU:**  
  A more detailed **in-order CPU model** with a fixed pipeline. It allows custom data structures and custom execution behavior. It is perfectly suited for simulations that require higher accuracy and more processing power without losing the in-order execution element.

---

### Writing and Executing a C Program in gem5

**"Write a program in C that implements the Fibonacci sequence and execute it in gem5 using different CPU models while keeping all other parameters the same. Use the TimingSimpleCPU and MinorCPU models."**

It is known that the statistics that are related to execution time are the following.

#### Execution Time Metrics Comparison with Default Settings

| **Metric**       | **Value (MinorCPU)** | **Value (TimingSimpleCPU)** | **Difference**      |
|------------------|----------------------|------------------------------|---------------------|
| final_tick       | 44,194,000           | 58,425,000                   | -14,231,000         |
| sim_seconds      | 0.000044             | 0.000058                     | -0.000014           |
| sim_ticks        | 44,194,000           | 58,425,000                   | -14,231,000         |

**Table 1:** Comparison of execution time metrics between MinorCPU and TimingSimpleCPU.

Due to the **MinorCPU's** ability to simulate pipeline processes explicitly, instructions run faster even though the CPU model is more detailed and accurate. **TimingSimpleCPU**, while simpler, does not include pipeline-level optimizations, leading to longer execution times.

#### Execution Time Metrics Comparison for TimingSimpleCPU and MinorCPU with DDR4 Memory Technology

| **Metric**         | **Value (MinorCPU)** | **Value (TimingSimpleCPU)** | **Difference**      |
|--------------------|----------------------|------------------------------|---------------------|
| final_tick         | 43,112,000           | 57,679,000                   | -14,567,000         |
| host_seconds       | 0.04                 | 0.01                         | 0.03                |
| host_tick_rate     | 1,064,720,573        | 4,108,076,185                | -3,043,355,612      |
| sim_seconds        | 0.000043             | 0.000058                     | -0.000015           |
| sim_ticks          | 43,112,000           | 57,679,000                   | -14,567,000         |

**Table 2:** Comparison of execution time metrics between MinorCPU and TimingSimpleCPU with DDR4 memory.

Once again, it is evident that **MinorCPU** outperforms **TimingSimpleCPU** due to its detailed pipeline, which improves instruction throughput and handles memory operations and delays more efficiently. Comparing the MinorCPU metrics from Table 1 and Table 2, we observe a slight improvement in performance in Table 2. This improvement can be attributed to the lower latency and higher bandwidth of DDR4 memory compared to DDR3.

#### Execution Time Metrics Comparison for TimingSimpleCPU and MinorCPU with 2GHz Clock Frequency

| **Metric**       | **Value (MinorCPU)** | **Value (TimingSimpleCPU)** | **Difference**      |
|------------------|----------------------|------------------------------|---------------------|
| final_tick       | 41,045,500           | 55,638,000                   | -14,592,500         |
| host_seconds     | 0.04                 | 0.01                         | 0.03                |
| host_tick_rate   | 1,042,979,640        | 4,817,522,837                | -3,774,543,197      |
| sim_seconds      | 0.000041             | 0.000056                     | -0.000015           |
| sim_ticks        | 41,045,500           | 55,638,000                   | -14,592,500         |

**Table 3:** Comparison of execution time metrics between MinorCPU and TimingSimpleCPU at 2GHz.

It is evident that the performance has increased compared to prior simulations. This is due to the higher CPU clock performance. A higher CPU frequency generally results in fewer ticks required for the same operations, leading to faster compilation time. The difference between **MinorCPU** and **TimingSimpleCPU** remains due to the inherent pipeline and execution model differences.

### Second Exercise

#### First Questions
**"Use your knowledge from the first part and locate in the relevant files the key parameters for the processor simulated by gem5 concerning the memory subsystem. Specifically, find the sizes of the caches (L1 instruction and L1 data caches as well as the L2 cache), the associativity of each of them, and the size of the cache line."**

### L1 Instruction Cache (I-Cache):
- **Size**: 32 KB
- **Associativity**: 2-way set associative
- **Cache Line Size**: 64 bytes

### L1 Data Cache (D-Cache):
- **Size**: 64 KB
- **Associativity**: 2-way set associative
- **Cache Line Size**: 64 bytes

### L2 Cache:
- **Size**: 2 MB
- **Associativity**: 8-way set associative
- **Cache Line Size**: 64 bytes

These settings match across all the key files.

#### Second Question
**"Record the results from the different benchmarks. Specifically, keep the following information from each benchmark:  
(i) execution time (note: the time required for the program to run on the simulated processor, not the time required by gem5 to perform the simulation),  
(ii) CPI (cycles per instruction), and  
(iii) overall miss rates for the L1 Data cache, L1 Instruction cache, and L2 cache.  
You can obtain this information from the `stats.txt` files. (Hint: for the first, look for the `sim_seconds` value, and for the third, search for entries like this: `icache.overall_miss_rate::total`).  
Create graphs to visualize this information for all the benchmarks. What do you observe?"**



| Benchmark | Execution Time (s) | CPI        | L1 I-Cache Miss Rate | L1 D-Cache Miss Rate | L2 Cache Miss Rate |
|-----------|---------------------|------------|-----------------------|-----------------------|--------------------|
| hmmer     | 0.059396            | 1.187917   | 0.000221              | 0.001637              | 0.07776            |
| bzip      | 0.083982            | 1.67965    | 0.000077              | 0.014798              | 0.282163           |
| libm      | 0.174671            | 3.493415   | 0.000094              | 0.060972              | 0.999944           |
| mcf       | 0.064955            | 1.299095   | 0.023612              | 0.002108              | 0.055046           |
| jeng      | 0.513528            | 10.270554  | 0.00002               | 0.121831              | 0.999972           |

### Third Question

**"Run the benchmarks in gem5 again in the same way as before, but this time add the parameters `--cpu-clock=1GHz` and `--cpu-clock=3GHz`. Examine the `stats.txt` files from the three executions of the program (the initial one and the ones with 1GHz and 3GHz) and identify the information about the clock. You will find two entries: one for `system.clk_domain.clock` and one for `cpu_cluster.clk_domain.clock`. Can you explain what is clocked at 1GHz/3GHz and what is clocked at the default GHz? Why do you think this happens?  
Refer to the `config.json` file corresponding to the system with 1GHz. By searching for information about the clock, can you provide a clearer answer?  
If we add another processor, what do you estimate its frequency will be?  
Observe the execution times of the benchmarks for systems with different clocks. Is there perfect scaling? Can you provide an explanation if there is no perfect scaling?  "**


1. **What is clocked at 1 GHz/3 GHz or default?**
   - Default: Both `system.clk_domain.clock` and `cpu_cluster.clk_domain.clock` follow default settings (assumed 1 GHz unless explicitly set).
   - With `--sys-clock=1GHz`: Both domains clocked at **1 GHz**.
   - With `--sys-clock=3GHz`: Both domains clocked at **3 GHz**.

2. **What happens if another processor is added?**
   - It inherits the clock frequency of the `system.clk_domain.clock` (e.g., 1 GHz or 3 GHz).

3. **Is there perfect scaling?**
   - No. Execution times show improvement (e.g., 0.16 s at 1 GHz to 0.058 s at 3 GHz) but not a perfect 3x speedup.

4. **Why is scaling not perfect?**
   - Due to architectural constraints, memory bottlenecks, and fixed simulation overheads unrelated to clock frequency.

### Fourth Question


| Configuration       | Execution Time (s) | CPI        | L1 I-Cache Miss Rate | L1 D-Cache Miss Rate | L2 Cache Miss Rate |
|---------------------|---------------------|------------|-----------------------|-----------------------|--------------------|
| **Default Memory**  | 0.174671           | 3.493415   | 0.000094             | 0.060972             | 0.999944           |
| **DDR3_2133_x64**   | 0.171530           | 3.430593   | 0.000094             | 0.060972             | 0.999944           |

### Observations:
1. **Execution Time**: Slight improvement in execution time with the faster memory.
2. **CPI**: Lower CPI with DDR3_2133_x64, indicating better overall processor efficiency due to reduced memory access latency.
3. **Miss Rates**:
   - **L1 I-Cache and L1 D-Cache** miss rates remain unchanged, as these are mostly influenced by the cache hierarchy and workload.
   - **L2 Cache Miss Rate** remains extremely high, implying the workload is heavily reliant on main memory and the faster DDR3 helps only marginally.


- Faster memory reduces memory latency but does not completely address the workload's bottlenecks. The high L2 cache miss rate indicates frequent accesses to main memory, where faster memory only provides diminishing returns.


### Second Step
**"Try to find the parameter values from the following list that will maximize the performance of your system for each benchmark:
L1 instruction cache size  
L1 instruction cache associativity  
L1 data cache size  
L1 data cache associativity  
L2 cache size  
L2 cache associativity  
Cache line size"**

Here are the results for each benchmark simulation. The Cache associativities were not deemed as important as the rest of the metrics so they were kept constant for the sake of time conservation.

## HMMER
| Benchmark Configuration                                              | CPI       | L1 D-Cache Miss Rate | L1 I-Cache Miss Rate | L2 Cache Miss Rate |
|----------------------------------------------------------------------|-----------|-----------------------|-----------------------|--------------------|
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 1.185304 | 0.001629              | 0.000221              | 0.077747           |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.180334 | 0.000879              | 0.000344              | 0.072074           |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz | 1.183580 | 0.000694              | 0.000212              | 0.179969           |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz| 1.178968 | 0.000386              | 0.000344              | 0.146335           |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 1.185060 | 0.001631              | 0.000087              | 0.080460           |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.179780 | 0.000880              | 0.000082              | 0.079899           |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz | 1.183287 | 0.000695              | 0.000087              | 0.193925           |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz| 1.178340 | 0.000387              | 0.000082              | 0.182442           |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.185304 | 0.001629              | 0.000221              | 0.077747           |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.180334 | 0.000879              | 0.000344              | 0.072074           |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz | 1.183580 | 0.000694              | 0.000212              | 0.179969           |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz| 1.178968 | 0.000386              | 0.000344              | 0.146335           |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.185060 | 0.001631              | 0.000087              | 0.080460           |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.179780 | 0.000880              | 0.000082              | 0.079899           |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz | 1.183287 | 0.000695              | 0.000087              | 0.193925           |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz| 1.178340 | 0.000387              | 0.000082              | 0.182442           |

 **Crucial Parameters**:
     - **L1 Instruction Cache Size and Associativity**: `hmmer` involves repeated fetching of code for statistical modeling. A larger instruction cache with high associativity reduces instruction fetch stalls.
     - **L2 Cache Size**: Bioinformatics workloads process large datasets, and a larger L2 cache can help in reducing memory access penalties.
   - **Why**: Efficient instruction caching is essential due to frequent branching and instruction reuse. L2 cache assists with data-intensive operations.




## BZIP2

| Benchmark Name                                                            | CPI       | L1 Data Cache Miss Rate | L1 Instruction Cache Miss Rate | L2 Cache Miss Rate |
|---------------------------------------------------------------------------|-----------|--------------------------|--------------------------------|---------------------|
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.564919 | 0.010685                | 0.000056                      | 0.209911           |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 1.597315 | 0.014274                | 0.000056                      | 0.154595           |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.573925 | 0.010702                | 0.000056                      | 0.236481           |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 1.606366 | 0.014290                | 0.000056                      | 0.174167           |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.573904 | 0.010701                | 0.000067                      | 0.236486           |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.581525 | 0.011621                | 0.000077                      | 0.363007           |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 1.606309 | 0.014290                | 0.000067                      | 0.174178           |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 1.609942 | 0.014672                | 0.000077                      | 0.282140           |

**Crucial Parameters**: 
     - **L1 Data Cache Size and Associativity**: `bzip2` performs repetitive operations on small chunks of data during compression, which benefits from a well-optimized L1 Data Cache. Insufficient size or associativity can lead to cache misses.
     - **L2 Cache Size**: Larger datasets and intermediate results might spill over into L2. The size of the L2 cache helps reduce the performance penalty from accessing main memory.
   - **Why**: The benchmark's memory access patterns involve small, localized chunks of data. Optimizing L1 and L2 caches minimizes data latency.


## MCF

| **Configuration**                             | **CPI**   | **L1 D-Cache Miss Rate** | **L1 I-Cache Miss Rate** | **L2 Cache Miss Rate** |
|-----------------------------------------------|-----------|--------------------------|--------------------------|------------------------|
| l1i32kB_l1d64kB_l22MB_line64_cpu1GHz          | 1.279422  | 0.002108                 | 0.023627                 | 0.055046              |
| l1i32kB_l1d64kB_l22MB_line128_cpu1GHz         | 1.320485  | 0.001384                 | 0.034839                 | 0.020630              |
| l1i32kB_l1d64kB_l24MB_line64_cpu1GHz          | 1.279161  | 0.002108                 | 0.023626                 | 0.054613              |
| l1i32kB_l1d64kB_l24MB_line128_cpu1GHz         | 1.320286  | 0.001384                 | 0.034838                 | 0.020419              |
| l1i32kB_l1d128kB_l22MB_line64_cpu1GHz         | 1.278449  | 0.001932                 | 0.023627                 | 0.055391              |
| l1i32kB_l1d128kB_l22MB_line128_cpu1GHz        | 1.319366  | 0.001180                 | 0.034835                 | 0.020749              |
| l1i32kB_l1d128kB_l24MB_line64_cpu1GHz         | 1.278180  | 0.001932                 | 0.023627                 | 0.054963              |
| l1i32kB_l1d128kB_l24MB_line128_cpu1GHz        | 1.319174  | 0.001180                 | 0.034834                 | 0.020544              |
| l1i64kB_l1d64kB_l22MB_line64_cpu1GHz          | 1.139457  | 0.002108                 | 0.000018                 | 0.711865              |
| l1i64kB_l1d64kB_l22MB_line128_cpu1GHz         | 1.113017  | 0.001384                 | 0.000020                 | 0.529297              |
| l1i64kB_l1d64kB_l24MB_line64_cpu1GHz          | 1.139146  | 0.002108                 | 0.000018                 | 0.706401              |
| l1i64kB_l1d64kB_l24MB_line128_cpu1GHz         | 1.112796  | 0.001384                 | 0.000020                 | 0.524081              |
| l1i64kB_l1d128kB_l22MB_line64_cpu1GHz         | 1.138112  | 0.001932                 | 0.000018                 | 0.776058              |
| l1i64kB_l1d128kB_l22MB_line128_cpu1GHz        | 1.111745  | 0.001180                 | 0.000020                 | 0.624600              |
| l1i64kB_l1d128kB_l24MB_line64_cpu1GHz         | 1.137956  | 0.001932                 | 0.000018                 | 0.770179              |
| l1i64kB_l1d128kB_l24MB_line128_cpu1GHz        | 1.111593  | 0.001180                 | 0.000020                 | 0.618629              |

**Crucial Parameters**:
     - **L2 Cache Size and Associativity**: `mcf` accesses sparse data structures, leading to irregular memory patterns that frequently bypass L1 caches. A larger and more associative L2 cache can reduce main memory accesses.
     - **L1 Instruction Cache Associativity**: While L1 instruction caching is less critical for `mcf`, the associativity can mitigate conflicts caused by irregular instruction fetching.
   - **Why**: The irregular and sparse nature of `mcf`'s memory access patterns makes it heavily dependent on the L2 cache to bridge the gap between L1 misses and memory accesses.


## SJENG
| **Configuration**                             | **CPI**    | **L1 D-Cache Miss Rate** | **L1 I-Cache Miss Rate** | **L2 Cache Miss Rate** |
|-----------------------------------------------|------------|--------------------------|--------------------------|------------------------|
| specsjeng_l1i32kB_l1d64kB_l22MB_line64        | 7.040276   | 0.121831                 | 0.000020                 | 0.999972              |
| specsjeng_l1i32kB_l1d64kB_l22MB_line128       | 4.974806   | 0.060922                 | 0.000015                 | 0.999824              |
| specsjeng_l1i32kB_l1d128kB_l22MB_line64       | 7.040343   | 0.121831                 | 0.000020                 | 0.999976              |
| specsjeng_l1i32kB_l1d128kB_l22MB_line128      | 4.974776   | 0.060921                 | 0.000015                 | 0.999856              |
| specsjeng_l1i64kB_l1d64kB_l22MB_line64        | 7.043379   | 0.121831                 | 0.000019                 | 0.999979              |
| specsjeng_l1i64kB_l1d64kB_l22MB_line128       | 4.974854   | 0.060922                 | 0.000013                 | 0.999846              |
| specsjeng_l1i64kB_l1d128kB_l22MB_line64       | 7.040244   | 0.121831                 | 0.000019                 | 0.999983              |
| specsjeng_l1i64kB_l1d128kB_l22MB_line128      | 4.974881   | 0.060921                 | 0.000013                 | 0.999877              |
| specsjeng_l1i32kB_l1d64kB_l24MB_line64        | 7.038783   | 0.121831                 | 0.000020                 | 0.999972              |
| specsjeng_l1i32kB_l1d64kB_l24MB_line128       | 4.972564   | 0.060922                 | 0.000015                 | 0.999824              |
| specsjeng_l1i32kB_l1d128kB_l24MB_line64       | 7.038783   | 0.121831                 | 0.000020                 | 0.999976              |
| specsjeng_l1i32kB_l1d128kB_l24MB_line128      | 4.972564   | 0.060921                 | 0.000015                 | 0.999856              |
| specsjeng_l1i64kB_l1d64kB_l24MB_line64        | 7.038702   | 0.121831                 | 0.000019                 | 0.999979              |
| specsjeng_l1i64kB_l1d64kB_l24MB_line128       | 4.972596   | 0.060922                 | 0.000013                 | 0.999846              |
| specsjeng_l1i64kB_l1d128kB_l24MB_line64       | 7.038696   | 0.121831                 | 0.000019                 | 0.999983              |
| specsjeng_l1i64kB_l1d128kB_l24MB_line128      | 4.972596   | 0.060921                 | 0.000013                 | 0.999877              |

**Crucial Parameters**:
     - **L1 Instruction Cache Size and Associativity**: The chess engine involves significant branching and decision-making, relying on quick instruction fetches to evaluate moves.
     - **L1 Data Cache Associativity**: Decision-making benefits from localized data caching, where associativity helps minimize cache conflicts.
   - **Why**: The benchmark's workload is instruction-heavy with frequent decision tree evaluations. A well-configured L1 cache ensures smooth instruction flow and data access.

### L1 & L2 Cache sizes Constant // Associativity 8 16
| **Benchmark**                                                      | **CPI**   | **L1 D-Cache Miss Rate** | **L1 I-Cache Miss Rate** | **L2 Cache Miss Rate** |
|--------------------------------------------------------------------|-----------|--------------------------|--------------------------|------------------------|
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc8_line128_cpu1GHz_new | 4.972548  | 0.060918                 | 0.000013                 | 0.999973              |
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc8_line256_cpu1GHz_new | 3.714674  | 0.030461                 | 0.000009                 | 0.999950              |
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc16_line128_cpu1GHz_new | 4.972063  | 0.060918                 | 0.000013                 | 0.999973              |
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc16_line256_cpu1GHz_new | 3.714674  | 0.030461                 | 0.000009                 | 0.999950              |
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc16_line_cpu1GHz_new_256cacheline | 3.714674  | 0.030461                 | 0.000009                 | 0.999950              |
| specsjeng_l1i64kB_l1iassoc4_l1d64kB_l1dassoc4_l24MB_l2assoc8_line_cpu1GHz_new_256cacheline  | 3.714674  | 0.030461                 | 0.000009                 | 0.999950              |



## LIBM

| **Benchmark**                                                      | **CPI**   | **L1 D-Cache Miss Rate** | **L1 I-Cache Miss Rate** | **L2 Cache Miss Rate** |
|--------------------------------------------------------------------|-----------|--------------------------|--------------------------|------------------------|
| speclibm_l1i32kB_l1d64kB_l22MB_l2assoc4_line64_cpu1GHz             | 2.623265  | 0.060971                 | 0.000094                 | 0.999944              |
| speclibm_l1i32kB_l1d64kB_l22MB_l2assoc4_line128_cpu1GHz            | 1.990458  | 0.030487                 | 0.000112                 | 0.999799              |
| speclibm_l1i32kB_l1d64kB_l22MB_l2assoc8_line64_cpu1GHz             | 2.623265  | 0.060971                 | 0.000094                 | 0.999944              |
| speclibm_l1i32kB_l1d64kB_l22MB_l2assoc8_line128_cpu1GHz            | 1.990458  | 0.030487                 | 0.000112                 | 0.999799              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc4_line64_cpu1GHz             | 2.620756  | 0.060971                 | 0.000094                 | 0.999944              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc4_line128_cpu1GHz            | 1.989132  | 0.030487                 | 0.000112                 | 0.999799              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc8_line64_cpu1GHz             | 2.620756  | 0.060971                 | 0.000094                 | 0.999944              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc8_line128_cpu1GHz            | 1.989132  | 0.030487                 | 0.000112                 | 0.999799              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc16_line128_cpu1GHz           | 1.989132  | 0.030487                 | 0.000112                 | 0.999799              |
| speclibm_l1i32kB_l1d64kB_l24MB_l2assoc16_line256_cpu1GHz           | 1.653896  | 0.015244                 | 0.000134                 | 0.999474              |

- **Crucial Parameters**:
     - **L1 Data Cache Size**: Continuous streaming of data for simulation benefits from a large L1 Data Cache to keep working sets close to the processor.
     - **L2 Cache Size**: Larger datasets frequently spill into L2. A larger cache helps prevent memory bottlenecks.
   - **Why**: `lbm` requires high memory bandwidth and frequent reuse of floating-point data. A well-optimized L1 and L2 cache hierarchy ensures minimal stalls during data fetches.


### Third Exercise

## Cost Function. 


---

The cost function selected is as follows:

$$ C = a \cdot S + b \cdot T $$

where:

- \( S \) is the parameter related to the circuit size.
- \( T \) is the parameter linked to the system's speed.
- \( a \) and \( b \) are weights.  

In this scenario, \( a \) and \( b \) are both set to 0.5 because the size and speed are deemed equally important. 

Expanding the formula for \( S \):

$$ S = k_1 \cdot M_{\text{cache}} + k_2 \cdot A $$

Here, `M_cache` is further expressed as:

$$ M_cache = w_1 \cdot M_{L1i} + w_2 \cdot M_{L1d} + w_3 \cdot M_{L2} $$

where:

- **`M_L1i`**: The size of the L1 instruction cache.
- **`M_L1d`**: The size of the L1 data cache.
- **`M_L2`**: The size of the L2 cache.
- **`w_1`, `w_2`, and `w_3`**: The weights associated with the respective cache levels.

This formulation balances circuit size and system speed to optimize the cost function (`C`) based on the given parameters and weights.

## Applying the function



---

The cost function is defined as:


$$ C = 0.7 \cdot \left( 0.4 \cdot M_{L1i} + 0.35 \cdot M_{L1d} + 0.25 \cdot M_{L2} \right) + 0.3 \cdot \left( 0.75 \cdot A_{L1} + 0.25 \cdot A_{L2} \right) $$

- **0.7**: The weight assigned to the miss rate component.
- **0.3**: The weight assigned to the access rate component.
- **0.4, 0.35, and 0.25**: The relative contributions of the L1 instruction cache, L1 data cache, and L2 cache to the miss rate, respectively.
- **0.75 and 0.25**: The relative contributions of the L1 and L2 caches to the access rate, respectively.

---

The exercise states that it is necessary to define an abstract value for the cost function. This value in this case is **omega** and it can be seen on this particular code snippet.

```python

 # Normalize cache sizes and associativity based on omega
    df["L1i_size_cost"] = (df["L1i_size_kB"] * 1) / omega  # Assume 1 kB = omega cost
    df["L1d_size_cost"] = (df["L1d_size_kB"] * 1) / omega
    df["L2_size_cost"] = (df["L2_size_MB"] * 1024) / omega  # Convert MB to kB
    
    df["L1i_assoc_cost"] = df["L1i_assoc"] / omega
    df["L2_assoc_cost"] = df["L2_assoc"] / omega
    
    # Calculate the components of the cost function
    df["M_cache"] = 0.4 * df["L1i_size_cost"] + 0.35 * df["L1d_size_cost"] + 0.25 * df["L2_size_cost"]
    df["A_cache"] = 0.75 * df["L1i_assoc_cost"] + 0.25 * df["L2_assoc_cost"]
    df["Performance"] = 0.7 * df["CPI"] + 0.3 * (0.5 * df["L1d_miss_rate"] + 0.3 * df["L1i_miss_rate"] + 0.2 * df["L2_miss_rate"])
    
    # Calculate the total cost
    df["Cost"] = 0.5 * (0.7 * df["M_cache"] + 0.3 * df["A_cache"]) + 0.5 * df["Performance"]
```    
## Tables for **sjeng**, **hmmer** and **bzip2**
| Benchmarks                                                                    |     CPI |   L1d_miss_rate |   L1i_miss_rate |   L2_miss_rate |   L1i_size_kB |   L1i_assoc |   L1d_size_kB |   L1d_assoc |   L2_size_MB |   L2_assoc |   L1i_size_cost |   L1d_size_cost |   L2_size_cost |   L1i_assoc_cost |   L2_assoc_cost |   M_cache |   A_cache |   Performance |    Cost |
|:------------------------------------------------------------------------------|--------:|----------------:|----------------:|---------------:|--------------:|------------:|--------------:|------------:|-------------:|-----------:|----------------:|----------------:|---------------:|-----------------:|----------------:|----------:|----------:|--------------:|--------:|
| specsjeng_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz   | 7.04028 |        0.121831 |         2e-05   |       0.999972 |            32 |           2 |            64 |           2 |            2 |          4 |             3.2 |             6.4 |          204.8 |              0.2 |             0.4 |     54.72 |      0.25 |       5.00647 | 21.6927 |
| specsjeng_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 4.97481 |        0.060922 |         1.5e-05 |       0.999824 |            32 |           2 |            64 |           2 |            2 |          4 |             3.2 |             6.4 |          204.8 |              0.2 |             0.4 |     54.72 |      0.25 |       3.55149 | 20.9652 |
| specsjeng_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 7.04034 |        0.121831 |         2e-05   |       0.999976 |            32 |           2 |           128 |           2 |            2 |          4 |             3.2 |            12.8 |          204.8 |              0.2 |             0.4 |     56.96 |      0.25 |       5.00652 | 22.4768 |
| specsjeng_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 4.97478 |        0.060921 |         1.5e-05 |       0.999856 |            32 |           2 |           128 |           2 |            2 |          4 |             3.2 |            12.8 |          204.8 |              0.2 |             0.4 |     56.96 |      0.25 |       3.55147 | 21.7492 |
| specsjeng_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz   | 7.04338 |        0.121831 |         1.9e-05 |       0.999979 |            64 |           2 |            64 |           2 |            2 |          4 |             6.4 |             6.4 |          204.8 |              0.2 |             0.4 |     56    |      0.25 |       5.00864 | 22.1418 |
| specsjeng_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 4.97485 |        0.060922 |         1.3e-05 |       0.999846 |            64 |           2 |            64 |           2 |            2 |          4 |             6.4 |             6.4 |          204.8 |              0.2 |             0.4 |     56    |      0.25 |       3.55153 | 21.4133 |
| specsjeng_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 7.04024 |        0.121831 |         1.9e-05 |       0.999983 |            64 |           2 |           128 |           2 |            2 |          4 |             6.4 |            12.8 |          204.8 |              0.2 |             0.4 |     58.24 |      0.25 |       5.00645 | 22.9247 |
| specsjeng_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 4.97488 |        0.060921 |         1.3e-05 |       0.999877 |            64 |           2 |           128 |           2 |            2 |          4 |             6.4 |            12.8 |          204.8 |              0.2 |             0.4 |     58.24 |      0.25 |       3.55155 | 22.1973 |
| specsjeng_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 7.03878 |        0.121831 |         2e-05   |       0.999972 |            32 |           2 |            64 |           2 |            4 |          4 |             3.2 |             6.4 |          409.6 |              0.2 |             0.4 |    105.92 |      0.25 |       5.00542 | 39.6122 |
| specsjeng_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 4.97256 |        0.060922 |         1.5e-05 |       0.999824 |            32 |           2 |            64 |           2 |            4 |          4 |             3.2 |             6.4 |          409.6 |              0.2 |             0.4 |    105.92 |      0.25 |       3.54992 | 38.8845 |
| specsjeng_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 7.03878 |        0.121831 |         2e-05   |       0.999976 |            32 |           2 |           128 |           2 |            4 |          4 |             3.2 |            12.8 |          409.6 |              0.2 |             0.4 |    108.16 |      0.25 |       5.00542 | 40.3962 |
| specsjeng_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 4.97256 |        0.060921 |         1.5e-05 |       0.999856 |            32 |           2 |           128 |           2 |            4 |          4 |             3.2 |            12.8 |          409.6 |              0.2 |             0.4 |    108.16 |      0.25 |       3.54993 | 39.6685 |
| specsjeng_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 7.0387  |        0.121831 |         1.9e-05 |       0.999979 |            64 |           2 |            64 |           2 |            4 |          4 |             6.4 |             6.4 |          409.6 |              0.2 |             0.4 |    107.2  |      0.25 |       5.00537 | 40.0602 |
| specsjeng_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 4.9726  |        0.060922 |         1.3e-05 |       0.999846 |            64 |           2 |            64 |           2 |            4 |          4 |             6.4 |             6.4 |          409.6 |              0.2 |             0.4 |    107.2  |      0.25 |       3.54995 | 39.3325 |
| specsjeng_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 7.0387  |        0.121831 |         1.9e-05 |       0.999983 |            64 |           2 |           128 |           2 |            4 |          4 |             6.4 |            12.8 |          409.6 |              0.2 |             0.4 |    109.44 |      0.25 |       5.00536 | 40.8442 |
| specsjeng_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 4.9726  |        0.060921 |         1.3e-05 |       0.999877 |            64 |           2 |           128 |           2 |            4 |          4 |             6.4 |            12.8 |          409.6 |              0.2 |             0.4 |    109.44 |      0.25 |       3.54995 | 40.1165 |




---
| Benchmarks                                                                    |     CPI |   L1d_miss_rate |   L1i_miss_rate |   L2_miss_rate |   L1i_size_kB |   L1i_assoc |   L1d_size_kB |   L1d_assoc |   L2_size_MB |   L2_assoc |   L1i_size_cost |   L1d_size_cost |   L2_size_cost |   L1i_assoc_cost |   L2_assoc_cost |   M_cache |   A_cache |   Performance |    Cost |
|:------------------------------------------------------------------------------|--------:|----------------:|----------------:|---------------:|--------------:|------------:|--------------:|------------:|-------------:|-----------:|----------------:|----------------:|---------------:|-----------------:|----------------:|----------:|----------:|--------------:|--------:|
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz   | 1.1853  |        0.001629 |        0.000221 |       0.077747 |            32 |           2 |            64 |           2 |            2 |          4 |             3.2 |             6.4 |          204.8 |              0.2 |             0.4 |     54.72 |      0.25 |      0.834642 | 19.6068 |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 1.18033 |        0.000879 |        0.000344 |       0.072074 |            32 |           2 |            64 |           2 |            2 |          4 |             3.2 |             6.4 |          204.8 |              0.2 |             0.4 |     54.72 |      0.25 |      0.830721 | 19.6049 |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 1.18358 |        0.000694 |        0.000212 |       0.179969 |            32 |           2 |           128 |           2 |            2 |          4 |             3.2 |            12.8 |          204.8 |              0.2 |             0.4 |     56.96 |      0.25 |      0.839427 | 20.3932 |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.17897 |        0.000386 |        0.000344 |       0.146335 |            32 |           2 |           128 |           2 |            2 |          4 |             3.2 |            12.8 |          204.8 |              0.2 |             0.4 |     56.96 |      0.25 |      0.834147 | 20.3906 |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz   | 1.18506 |        0.001631 |        8.7e-05  |       0.08046  |            64 |           2 |            64 |           2 |            2 |          4 |             6.4 |             6.4 |          204.8 |              0.2 |             0.4 |     56    |      0.25 |      0.834622 | 20.0548 |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 1.17978 |        0.00088  |        8.2e-05  |       0.079899 |            64 |           2 |            64 |           2 |            2 |          4 |             6.4 |             6.4 |          204.8 |              0.2 |             0.4 |     56    |      0.25 |      0.830779 | 20.0529 |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line64_cpu1GHz  | 1.18329 |        0.000695 |        8.7e-05  |       0.193925 |            64 |           2 |           128 |           2 |            2 |          4 |             6.4 |            12.8 |          204.8 |              0.2 |             0.4 |     58.24 |      0.25 |      0.840048 | 20.8415 |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.17834 |        0.000387 |        8.2e-05  |       0.182442 |            64 |           2 |           128 |           2 |            2 |          4 |             6.4 |            12.8 |          204.8 |              0.2 |             0.4 |     58.24 |      0.25 |      0.83585  | 20.8394 |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 1.1853  |        0.001629 |        0.000221 |       0.077747 |            32 |           2 |            64 |           2 |            4 |          4 |             3.2 |             6.4 |          409.6 |              0.2 |             0.4 |    105.92 |      0.25 |      0.834642 | 37.5268 |
| spechmmer_l1i32kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 1.18033 |        0.000879 |        0.000344 |       0.072074 |            32 |           2 |            64 |           2 |            4 |          4 |             3.2 |             6.4 |          409.6 |              0.2 |             0.4 |    105.92 |      0.25 |      0.830721 | 37.5249 |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.18358 |        0.000694 |        0.000212 |       0.179969 |            32 |           2 |           128 |           2 |            4 |          4 |             3.2 |            12.8 |          409.6 |              0.2 |             0.4 |    108.16 |      0.25 |      0.839427 | 38.3132 |
| spechmmer_l1i32kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.17897 |        0.000386 |        0.000344 |       0.146335 |            32 |           2 |           128 |           2 |            4 |          4 |             3.2 |            12.8 |          409.6 |              0.2 |             0.4 |    108.16 |      0.25 |      0.834147 | 38.3106 |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 1.18506 |        0.001631 |        8.7e-05  |       0.08046  |            64 |           2 |            64 |           2 |            4 |          4 |             6.4 |             6.4 |          409.6 |              0.2 |             0.4 |    107.2  |      0.25 |      0.834622 | 37.9748 |
| spechmmer_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 1.17978 |        0.00088  |        8.2e-05  |       0.079899 |            64 |           2 |            64 |           2 |            4 |          4 |             6.4 |             6.4 |          409.6 |              0.2 |             0.4 |    107.2  |      0.25 |      0.830779 | 37.9729 |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.18329 |        0.000695 |        8.7e-05  |       0.193925 |            64 |           2 |           128 |           2 |            4 |          4 |             6.4 |            12.8 |          409.6 |              0.2 |             0.4 |    109.44 |      0.25 |      0.840048 | 38.7615 |
| spechmmer_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.17834 |        0.000387 |        8.2e-05  |       0.182442 |            64 |           2 |           128 |           2 |            4 |          4 |             6.4 |            12.8 |          409.6 |              0.2 |             0.4 |    109.44 |      0.25 |      0.83585  | 38.7594 |

---

| Benchmarks                                                           | CPI       | L1d Miss Rate | L1i Miss Rate | L2 Miss Rate | L1i Size (kB) | L1i Assoc | L1d Size (kB) | L1d Assoc | L2 Size (MB) | L2 Assoc | L1i Size Cost | L1d Size Cost | L2 Size Cost | L1i Assoc Cost | L2 Assoc Cost | M Cache | A Cache | Performance | Cost       |
|---------------------------------------------------------------------------|-----------|---------------|---------------|--------------|---------------|-----------|---------------|-----------|--------------|----------|---------------|---------------|--------------|----------------|---------------|---------|---------|-------------|------------|
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz | 1.564919 | 0.010685      | 0.000056      | 0.209911     | 64            | 2         | 128           | 2         | 4            | 4        | 6.4           | 12.8          | 409.6        | 0.2            | 0.4           | 109.44  | 0.25    | 1.109646    | 38.896323  |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line128_cpu1GHz  | 1.597315 | 0.014274      | 0.000056      | 0.154595     | 64            | 2         | 64            | 2         | 4            | 4        | 6.4           | 6.4           | 409.6        | 0.2            | 0.4           | 107.20  | 0.25    | 1.129542    | 38.122271  |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz | 1.573925 | 0.010702      | 0.000056      | 0.236481     | 64            | 2         | 128           | 2         | 2            | 4        | 6.4           | 12.8          | 204.8        | 0.2            | 0.4           | 58.24   | 0.25    | 1.117547    | 20.980273  |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l22MB_l2assoc4_line128_cpu1GHz  | 1.606366 | 0.014290      | 0.000056      | 0.174167     | 64            | 2         | 64            | 2         | 2            | 4        | 6.4           | 6.4           | 204.8        | 0.2            | 0.4           | 56.00   | 0.25    | 1.137055    | 20.206027  |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.573904 | 0.010701      | 0.000067      | 0.236486     | 64            | 2         | 128           | 2         | 4            | 4        | 6.4           | 12.8          | 409.6        | 0.2            | 0.4           | 109.44  | 0.25    | 1.117533    | 38.900267  |
| specbzip_l1i64kB_l1iassoc2_l1d128kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz  | 1.581525 | 0.011621      | 0.000077      | 0.363007     | 64            | 2         | 128           | 2         | 4            | 4        | 6.4           | 12.8          | 409.6        | 0.2            | 0.4           | 109.44  | 0.25    | 1.117533    | 38.900267  |
| specbzip_l1i64kB_l1iassoc2_l1d64kB_l1dassoc2_l24MB_l2assoc4_line64_cpu1GHz   | 1.609942 | 0.014672      | 0.000077      | 0.282140     | 64            | 2         | 64            | 2         | 4            | 4        | 6.4           | 6.4           | 409.6        | 0.2            | 0.4           | 107.20  | 0.25    | 1.129542    | 38.122271  |

---

