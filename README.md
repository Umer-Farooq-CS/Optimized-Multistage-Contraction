# Quantum Circuit Simulation with Tensor Networks

This project focuses on simulating quantum circuits using tensor networks and implementing parallel algorithms to enhance performance. The simulation leverages the concept of Matrix Product States (MPS) and employs OpenCL for parallel execution.

## Project Overview

The primary objective is to simulate quantum circuits by representing the quantum state as an MPS tensor network. This approach allows for efficient computation of quantum observables and facilitates the simulation of large quantum systems. The project also explores parallelization techniques using OpenCL to accelerate the simulation process.

## Features

- **Quantum Circuit Simulation**: Simulate quantum circuits by representing the quantum state as an MPS tensor network.
- **Parallel Execution**: Utilize OpenCL to parallelize the tensor contraction process, enhancing performance.
- **Scalability**: Evaluate the scalability of the simulation by testing with various quantum circuits and system sizes.

## Prerequisites

To run the simulation and parallel execution, ensure the following dependencies are installed:

- **Python**: Version 3.7 or higher
- **NumPy**: For numerical operations
- **pyopencl**: For OpenCL bindings in Python
- **OpenCL**: Ensure that your system has an OpenCL-compatible device and the necessary drivers installed

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/quantum-circuit-simulation.git
   cd quantum-circuit-simulation

2. Install Python dependencies:

  ```bash
  pip install -r requirements.txt
  ```

3. Ensure OpenCL is set up on your system. Refer to your device manufacturer's instructions for installation.

## Usage

### Serial Simulation

  To run the quantum circuit simulation in serial mode:
  
  ```bash
    python simulate.py --serial
  ```
  
  This command will execute the simulation without parallelization, providing a baseline performance measurement.

### Parallel Simulation with OpenCL

  To run the simulation with parallel execution using OpenCL:

  ```bash
    python simulate.py --parallel
  ```
  This command will utilize OpenCL to parallelize the tensor contraction process, aiming to improve performance.

## Project Structure

  ```bash
quantum-circuit-simulation/
├── src/
│   ├── simulate.py          # Main simulation script
│   ├── tensor_network.py    # Tensor network operations
│   └── opencl_utils.py      # OpenCL utility functions
├── tests/
│   └── test_simulation.py   # Unit tests for simulation
├── requirements.txt         # Python dependencies
└── README.md                # Project documentation

```








