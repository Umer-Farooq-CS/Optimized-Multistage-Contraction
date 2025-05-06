# This script is designed to run the contraction algorithm for quantum circuits using the ComPar algorithm. 
# It includes setup for package installation, circuit creation, and contraction execution. 
# The script also includes timing and profiling for performance analysis.
# The script is intended to be run in a Julia environment with the necessary packages installed.

# if !isdefined(Main, :packages_installed)
#     println("First-time setup: Installing required packages...")
#     import Pkg
#     Pkg.add("TimerOutputs")
#     Pkg.add("ProfileView")
#     Pkg.add("QXTools")
#     Pkg.add("QXGraphDecompositions")
#     Pkg.add("QXZoo")
#     Pkg.add("DataStructures")
#     Pkg.add("QXTns")
#     Pkg.add("NDTensors")
#     Pkg.add("ITensors")
#     Pkg.add("LightGraphs")
#     Pkg.add("PyCall")
#     Pkg.add("FlameGraphs")
#     Pkg.add("LLVMOpenMP_jll")
#     Pkg.add("ParallelStencil")
#     global packages_installed = true
# end

using TimerOutputs
using Profile
using ProfileView
using QXTools
using QXTns
using QXZoo
using PyCall
using QXGraphDecompositions
using LightGraphs
using DataStructures
using ITensors
using LinearAlgebra
using NDTensors
using FlameGraphs
using LLVMOpenMP_jll
using ParallelStencil

const to = TimerOutput()

@timeit to "Load Custom Functions" begin
    include("../functions_article.jl")
end

@timeit to "Main Program" begin
    # Create a QFT circuit with 10 qubits
    n = 10
    ng = 3  # for rqc circuits
    depth = 16
    seed = 41

    @timeit to "Circuit Creation" begin
        # circuit = create_ghz_circuit(n)
        # circuit = create_qft_circuit(n)
        circuit = create_rqc_circuit(ng, ng, depth, seed, final_h=true)
        println("Created circuit with ", circuit.num_qubits, " qubits")
    end

    # Configure the contraction algorithm
    num_communities = 4
    input = "0"^100
    output = "0"^100

    @timeit to "TNC Conversion" begin
        convert_to_tnc(circuit; input=input, output=output, decompose=true)
        println("Successfully converted to TNC")
    end

    # Run the ComPar algorithm using multicore CPU
    @timeit to "Contraction" begin
        try
            Profile.@profile begin
                result = ComParCPU(circuit, input, output, num_communities; timings=true)
                println("Contraction result: ", result)
                
                # Save results to file
                output_file = "results_default.txt"
                open(output_file, "w") do f
                    println(f, "Circuit: RQC $(ng)x$(ng), depth $(depth), seed $(seed)")
                    println(f, "Result: $(result)")
                    println(f, "\nTiming Results:")
                    show(f, to, allocations=true, sortby=:firstexec)
                end
                println("Results saved to $(output_file)")
            end
        catch e
            println("Error during contraction: ", e)
            rethrow(e)
        end
    end
end

# Display timing results
println("\n\n" * repeat("=", 82))
println("Timing Results:")
show(to, allocations=true, sortby=:firstexec)
println("\n" * repeat("=", 82))