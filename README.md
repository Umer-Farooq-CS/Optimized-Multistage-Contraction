# Quantum Circuit Simulation with Tensor Networks

A high-performance Julia library for simulating quantum circuits using tensor network contraction with community detection algorithms.

## Project Overview

The primary objective is to simulate quantum circuits by representing the quantum state as an MPS tensor network. This approach allows for efficient computation of quantum observables and facilitates the simulation of large quantum systems. The project also explores parallelization techniques using OpenCL to accelerate the simulation process.

## Features

- **Quantum Circuit Simulation**: Quantum Fourier Transform (QFT) circuit simulation
- **Parallel Execution**: Parallel tensor contraction using Julia's multithreading and OpenMP
- **Scalability**: Evaluate the scalability of the simulation by testing with various quantum circuits and system sizes.

## Prerequisites

To run the simulation and parallel execution, ensure the following dependencies are installed:

- **Python**: Version 3.11
- **Julia**: For simulating quantum circuits
- **OpenMP**: For Parallelization
- **Essential Libraries**: Add following in Julia
- 
   ```bash
      import Pkg
      Pkg.add("TimerOutputs")
      Pkg.add("ProfileView")
      Pkg.add("QXTools")
      Pkg.add("QXGraphDecompositions")
      Pkg.add("QXZoo")
      Pkg.add("DataStructures")
      Pkg.add("QXTns")
      Pkg.add("NDTensors")
      Pkg.add("ITensors")
      Pkg.add("LightGraphs")
      Pkg.add("PyCall")
      Pkg.add("Metis")
      Pkg.add("SparseArrays")
      Pkg.add("Statistics")
      Pkg.add("FlameGraphs")
      global packages_installed = true
   ```
   
   

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Umer-Farooq-CS/Optimized-Multistage-Contraction.git

2. Install julia dependencies:
   - Download and install Julia from [https://julialang.org/](https://julialang.org/).

3. Ensure Libraries are already installed

## Usage
1. For running Basic Code (Using ComPar Algorithm):

   ```bash
       julia --project=. --track-allocation=user default.jl
   
2. For running OpenMP Code:

   ```bash
      julia --project=. --track-allocation=user OpenMP.jl
   
3. For running Final Code (Metis + OpenMP)

   ```bash
      julia --project=. --track-allocation=user Final.jl
   
## Project Structure

  ```bash

Optimized-Multistage-Contraction
├── src/
│   ├──scripts/
│   │   ├── Final.jl
│   │   ├── OpenMP.jl
│   │   ├── default.jl
│   ├── METIS_partitioning.jl          # Contain Helper Functions for METIS and OpenMP
│   ├── TensorContraction_OpenMP.jl    # Contain Helper Functions for OpenMP
│   └── functions_article.jl           # Contain Helper Functions for ComPar and Creating Circuits
├── Report/
│   └── PDC Project Report.pdf
├── Presentation/
│   └── 22I-0891_22I-0893_22I-0911_D.pptx
│   └── A Community Detection-Based Parallel Algorithm for Quantum Circuit Simulation.pdf

```








