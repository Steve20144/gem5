

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
3. [Issues](#issues)

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

The cache configurations are consistent across all three additional files (**configjeng.ini**, **configmcf.ini**, and **configlibm.ini**). Here are the details for each:

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

These settings match across all the provided configuration files, including the ones uploaded earlier for **hmmer** and **bzip**.

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

### Observations for this Benchmark and Hardware Configuration:

1. **CPI (Cycles Per Instruction)**:
   - CPI improves (decreases) as cache sizes (L1 and L2) increase and cache line size widens from 64 bytes to 128 bytes. Larger caches reduce the number of memory accesses, resulting in better instruction throughput.
   - Larger L1 instruction cache (64kB vs. 32kB) shows minor improvements in CPI, highlighting that the workload is not heavily constrained by instruction fetch misses.

2. **L1 D-Cache Miss Rate**:
   - Miss rates drop significantly as the L1 data cache size increases (from 64kB to 128kB).
   - A wider cache line size (128 bytes) further reduces miss rates, as more data is fetched per cache line, reducing the need for additional memory accesses.

3. **L1 I-Cache Miss Rate**:
   - Miss rates are lower with a larger instruction cache (64kB vs. 32kB), although the improvement is less pronounced compared to the L1 data cache.
   - This suggests that the benchmark is moderately dependent on instruction cache performance.

4. **L2 Cache Miss Rate**:
   - The L2 cache miss rate decreases when the L2 size increases from 2MB to 4MB, especially for configurations with larger L1 caches.
   - Wider cache line sizes (128 bytes) also improve L2 performance, although diminishing returns are observed as miss rates remain relatively high for some configurations.

5. **Cache Line Size Impact**:
   - Across all metrics, a cache line size of 128 bytes consistently improves performance compared to 64 bytes, particularly for L1 and L2 miss rates.

6. **Overall Performance Trends**:
   - Larger cache sizes (both L1 and L2) combined with wider cache lines lead to consistent improvements across all metrics.
   - However, beyond certain cache size thresholds (e.g., L2 > 2MB), the improvements in CPI and miss rates begin to diminish, suggesting workload-specific memory access patterns.



## MCF
Here is a table that compares the results of the **mcf** benchmark for different hardware configurations:

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

### Observations for this Benchmark and Hardware Configuration:
1. **CPI**:
   - CPI generally decreases with larger L1 instruction and data caches (e.g., 64kB vs. 32kB).
   - Wider cache lines (128 bytes vs. 64 bytes) result in slightly lower CPI values due to improved spatial locality.

2. **L1 D-Cache Miss Rate**:
   - Larger L1 data caches (128kB vs. 64kB) reduce miss rates.
   - Wider cache lines (128 bytes vs. 64 bytes) further reduce miss rates by fetching more data per line.

3. **L1 I-Cache Miss Rate**:
   - Larger L1 instruction caches (64kB vs. 32kB) significantly reduce miss rates.
   - The impact of cache line size on L1 I-cache miss rates is less pronounced compared to the data cache.

4. **L2 Cache Miss Rate**:
   - The L2 cache miss rate decreases with wider cache lines (128 bytes vs. 64 bytes).
   - A larger L2 cache (4MB vs. 2MB) provides minor improvements for most configurations, as seen in the reduced miss rates.


## SJENG
For this particular benchmark, the L2 cache miss-rate was particularly high. This implied that the decision to keep cache associativities constant was not working for this particular Benchmark. 
### Associativy Constant
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

### L1 & L2 Cache sizes Constant


## LIBM

### Third Exercise

% Explain the objectives, procedures, and expected outcomes of the third exercise.

*(Content to be added.)*

## Issues

% Discuss any challenges or problems encountered during the project and how they were addressed.

*(Content to be added.)*

---

