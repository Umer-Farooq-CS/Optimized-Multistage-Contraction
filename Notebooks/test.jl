# Add necessary packages
import Pkg; 
# Pkg.add("QXTools")
# Pkg.add("QXGraphDecompositions")
# Pkg.add("QXZoo")
# Pkg.add("DataStructures")
# Pkg.add("QXTns")
# Pkg.add("NDTensors")
# Pkg.add("ITensors")
# Pkg.add("LightGraphs")
# Pkg.add("PyCall")

# Using required modules
using QXTools
using QXTns
using QXZoo
using PyCall
using QXGraphDecompositions
using LightGraphs
using DataStructures
using TimerOutputs
using ITensors
using LinearAlgebra
using NDTensors

# Load custom functions from the folder src
include("../src/funcions_article.jl")

# Create a QFT circuit with 10 qubits
n = 10
ng = 3  # for rqc circuits
depth = 16
seed = 41

# circuit = create_ghz_circuit(n)
#circuit = create_qft_circuit(n)
circuit = create_rqc_circuit(ng, ng, depth, seed, final_h=true)

println("Created circuit with ", circuit.num_qubits, " qubits")

# Configure the contraction algorithm
num_communities = 4
input = "0"^100
output = "0"^100
convert_to_tnc(circuit; input=input, output=output, decompose=true)

println("Successfully converted to TNC")

# Run the ComPar algorithm using multicore CPU
try
    # result = ComParCPU(circuit, input_state, output_state, 4; timings=true)
    result = ComParCPU(circuit, input, output, num_communities; timings=true)
    println("Contraction result: ", result)
    println(result)
catch e
    println("Error during contraction: ", e)
    rethrow(e)
end