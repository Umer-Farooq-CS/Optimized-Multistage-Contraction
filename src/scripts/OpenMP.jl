# This script is designed to run quantum circuit contraction using OpenMP parallelization
# It includes timing and profiling for performance analysis

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
#     global packages_installed = true
# end

using TimerOutputs
using Profile
using ProfileView
using QXTools
using QXTns
using QXZoo
using QXGraphDecompositions
using LightGraphs
using DataStructures
using ITensors
using LinearAlgebra
using NDTensors
using FlameGraphs
using LLVMOpenMP_jll

# Create timer
const to = TimerOutput()

# Define OpenMP helper functions
@timeit to "Define Helper Functions" begin
    function set_openmp_threads(n::Int)
        ENV["OMP_NUM_THREADS"] = string(n)
        ccall((:omp_set_num_threads, LLVMOpenMP_jll.libomp), Cvoid, (Cint,), n)
        return n
    end

    function get_openmp_threads()
        threads = ccall((:omp_get_max_threads, LLVMOpenMP_jll.libomp), Cint, ())
        return Int(threads)
    end
end

@timeit to "Load Custom Functions" begin
    include("../TensorContraction_OpenMP.jl")
end

@timeit to "Main Program" begin
    # Set Julia's threading environment variable before running
    # This is in addition to OpenMP threads
    @timeit to "Configure Threads" begin
        ENV["JULIA_NUM_THREADS"] = "8"
        ENV["OMP_NUM_THREADS"] = "8"
        num_threads = 8  # Set to the number of cores you want to use
        
        # Configure OpenMP
        set_openmp_threads(num_threads)
        actual_threads = get_openmp_threads()
        println("Confirmed OpenMP threads: ", actual_threads)
    end

    # Create a circuit
    @timeit to "Circuit Creation" begin
        n = 10
        circuit = create_qft_circuit(n)
        println("Created QFT circuit with ", n, " qubits")
    end

    # Configure the contraction algorithm
    num_communities = 4
    input = "0"^n
    output = "0"^n

    @timeit to "TNC Conversion" begin
        convert_to_tnc(circuit; input=input, output=output, decompose=true)
        println("Successfully converted to TNC")
    end

    # Run the contraction with OpenMP
    @timeit to "OpenMP Contraction" begin
        Profile.@profile begin
            try
                result = ComParCPU_OpenMP(circuit, input, output, num_communities, num_threads)
                println("Contraction result: ", result)
                
                # Save results to file
                output_file = "results_OpenMP.txt"
                open(output_file, "w") do f
                    println(f, "Circuit: QFT $(n) qubits")
                    println(f, "Communities: $(num_communities)")
                    println(f, "Threads: $(num_threads)")
                    println(f, "Result: $(result)")
                    println(f, "\nTiming Results:")
                    show(f, to, allocations=true, sortby=:firstexec)
                end
                println("Results saved to $(output_file)")
            catch e
                println("Error during contraction: ", e)
                println("Error type: ", typeof(e))
                for (exc, bt) in Base.catch_stack()
                    showerror(stdout, exc, bt)
                    println()
                end
            end
        end
    end
end

# Display timing results
println("\n\n" * repeat("=", 82))
println("Timing Results:")
show(to, allocations=true, sortby=:firstexec)
println("\n" * repeat("=", 82))