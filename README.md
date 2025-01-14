---
title: "gem5 Report"
author: "Stefanos Fragoulis"
date: "January 2025"
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
        - [Some Information on Different CPU Models](#some-information-on-different-cpu-models)
    - [Second Exercise](#second-exercise)
    - [Third Exercise](#third-exercise)
3. [Issues](#issues)

---

## Chapter 1: Introduction & Preface

% Introduce gem5, the purpose of the report, and provide an overview of what will be covered.

gem5 is an open-source, modular simulation platform widely used in computer architecture research and development. It allows researchers and engineers to model and analyze the behavior of computer systems, including CPUs, memory hierarchies, caches, and interconnects. By providing a flexible and extensible framework, gem5 supports multiple processor architectures such as x86, ARM, and RISC-V, as well as various system configurations.

The platform is instrumental for performance analysis, enabling the evaluation and optimization of both hardware components and software applications. It serves as a valuable tool for research and development, allowing experimentation with new architectural features, memory systems, and caching strategies. Additionally, gem5 is utilized for educational purposes, helping students and professionals understand the intricacies of computer architecture and system design. By combining different simulation techniques, including cycle-accurate and system-level modeling, gem5 offers detailed insights into the interactions between hardware and software. Its versatility and comprehensive capabilities make gem5 an essential tool for advancing computer architecture innovations and optimizing system performance.

gem5 was originally conceived for computer architecture research in academia, but it has grown to be used in computer system design by academia, industry for research, and in teaching.

The purpose of this project was to familiarize the students with the gem5 tool, as it is one of the most widely-used tools in the field of Computer Architecture.

### Environment Setup

% Describe the system requirements, installation steps, and verification process for setting up gem5.

For this project, a Virtual Machine with gem5 installed was utilized to avoid unnecessary installation and dependency issues. The VM was provided by the assignment PDF and was executed on VirtualBox with 12 processors and 16GB of RAM.

## Chapter 2: Exercises

% Outline the objectives, procedures, and expected outcomes of the first exercise.

The first exercise aims at setting the foundations for understanding the functionality and operation of the gem5 simulation tool. This includes an initial read of the gem5 documentation, a fundamental exploration of the various CPU models, and an evaluation of the significance of the `stats.txt` file in performance analysis. Moreover, the exercise encourages students to experiment with different memory configurations, CPU architectures, and diverse CPU frequencies to gain practical insights into their impact on system behavior and performance.

### First Exercise

#### First Question

**"Open the `starter_se.py` that was utilized in the prior "Hello World" example and try to understand the basic parameters that gem5 uses regarding the emulated system. Write down basic system characteristics such as CPU type, operation frequency, basic units, caches, memory, etc."**

- **CPU Type:**  
  The script uses a dictionary `cpu_types` alongside a `--cpu` argument. The `cpu_types` dictionary is the following:

  ```python
  cpu_types = {
      "atomic" : ( AtomicSimpleCPU, None, None, None, None),
      "minor" : (MinorCPU,
                 devices.L1I, devices.L1D,
                 devices.WalkCache,
                 devices.L2),
      "hpi" : ( HPI.HPI,
               HPI.HPI_ICache, HPI.HPI_DCache,
               HPI.HPI_WalkCache,
               HPI.HPI_L2)
  }
