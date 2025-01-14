Sure! Here's your LaTeX document converted into Markdown:

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

% Introduce gem5, the purpose of the report, and provide an overview of what will be covered.

gem5 is an open-source, modular simulation platform widely used in computer architecture research and development. It allows researchers and engineers to model and analyze the behavior of computer systems, including CPUs, memory hierarchies, caches, and interconnects. By providing a flexible and extensible framework, gem5 supports multiple processor architectures such as x86, ARM, and RISC-V, as well as various system configurations.

The platform is instrumental for performance analysis, enabling the evaluation and optimization of both hardware components and software applications. It serves as a valuable tool for research and development, allowing experimentation with new architectural features, memory systems, and caching strategies. Additionally, gem5 is utilized for educational purposes, helping students and professionals understand the intricacies of computer architecture and system design. By combining different simulation techniques, including cycle-accurate and system-level modeling, gem5 offers detailed insights into the interactions between hardware and software. Its versatility and comprehensive capabilities make gem5 an essential tool for advancing computer architecture innovations and optimizing system performance.

gem5 was originally conceived for computer architecture research in academia, but it has grown to be used in computer system design by academia, industry for research, and in teaching.

The purpose of this project was to familiarize the students with the gem5 tool, as it is one of the most widely-used tools in the field of Computer Architecture.

### Environment Setup

% Describe the system requirements, installation steps, and verification process for setting up gem5.

For this project, a Virtual Machine with gem5 installed was utilized to avoid unnecessary installation and dependency issues. The VM was provided by the assignment PDF and was executed on VirtualBox with 12 processors and 16GB of RAM.

## Exercises

% Outline the objectives, procedures, and expected outcomes of the first exercise.

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

**""**  
*(It appears the second question content is missing in your LaTeX document.)*

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

*(All of the generated files from the simulations will be included in the final zip.)*

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

% Detail the objectives, procedures, and expected outcomes of the second exercise.

*(Content to be added.)*

### Third Exercise

% Explain the objectives, procedures, and expected outcomes of the third exercise.

*(Content to be added.)*

## Issues

% Discuss any challenges or problems encountered during the project and how they were addressed.

*(Content to be added.)*

---

