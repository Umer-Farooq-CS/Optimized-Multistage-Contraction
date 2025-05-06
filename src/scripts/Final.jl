# This script is designed to run the METIS partitioning for quantum circuits
# along with comparing different community detection algorithms.
# It includes timing and profiling for performance analysis.

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
#     Pkg.add("Metis")
#     Pkg.add("SparseArrays")
#     Pkg.add("Statistics")
#     Pkg.add("FlameGraphs")
#     global packages_installed = true
# end

using TimerOutputs
using Profile
using ProfileView
using QXTools
using QXGraphDecompositions
using QXZoo
using DataStructures
using QXTns
using NDTensors
using ITensors
using LightGraphs
using Metis
using SparseArrays
using Statistics
using FlameGraphs

# Create a timer for measuring performance
const to = TimerOutput()

@timeit to "Load Custom Functions" begin
    include("../TensorContraction_OpenMP.jl")
    include("../METIS_partitioning.jl")
    
    # Set Julia's threading environment variable
    ENV["JULIA_NUM_THREADS"] = 8
    ENV["OMP_NUM_THREADS"] = 8
end

@timeit to "Main Program" begin
    @timeit to "Basic METIS Test" begin
        # Create a simple test graph
        n = 4  # number of vertices
        adjmat = sparse([1,1,2,2,3,3,4,4], [2,3,1,4,1,4,2,3], 1, n, n)
        
        # Convert to symmetric matrix (undirected graph)
        adjmat_sym = adjmat + adjmat'
        
        # Partition the graph
        nparts = 2
        edgecut, part = Metis.partition(adjmat_sym, nparts)
        
        println("Basic METIS test:")
        println("Edge cuts: ", edgecut)
        println("Partition vector: ", part)
        println()
    end

    @timeit to "Small Circuit Test" begin
        n_small = 8
        num_communities_small = 2
        num_threads_small = 4
        
        println("\n===== Testing Quantum Circuit with METIS Partitioning =====")
        println("Creating quantum circuit with $n_small qubits...")
        
        # Validate number of communities
        if num_communities_small < 1 || num_communities_small > n_small
            error("Number of communities must be between 1 and number of qubits ($n_small)")
        end
        
        @timeit to "Small Circuit Creation" begin
            circuit_small = create_qft_circuit(n_small)
            input_small = "0"^n_small
            output_small = "0"^n_small
        end
        
        println("Circuit created. Running contraction with METIS partitioning...")
        println("- Number of qubits: $n_small")
        println("- Number of communities: $num_communities_small")
        println("- Number of threads: $num_threads_small")
        
        @timeit to "Small Circuit Contraction" begin
            Profile.@profile begin
                try
                    result_small = ComParCPU_METIS(circuit_small, input_small, output_small, num_communities_small)
                    println("\nContraction successful!")
                    println("Result: ", result_small)
                    
                    # Save results to file
                    output_file_small = "results_metis_qft_n$(n_small)_c$(num_communities_small).txt"
                    open(output_file_small, "w") do f
                        println(f, "Circuit: QFT $(n_small) qubits")
                        println(f, "Communities: $(num_communities_small)")
                        println(f, "Result: $(result_small)")
                        println(f, "\nTiming Results:")
                        show(f, to, allocations=true, sortby=:firstexec)
                    end
                    println("Results saved to $(output_file_small)")
                catch e
                    println("Error during contraction: ", e)
                    showerror(stdout, e)
                    println()
                end
            end
        end
    end

    @timeit to "Compare Community Detection Methods" begin
        n_medium = 12
        num_communities_medium = 4
        
        println("\n===== Comparing Community Detection Methods =====")
        
        # Create quantum circuit
        @timeit to "Medium Circuit Creation" begin
            circuit_medium = create_qft_circuit(n_medium)
            input_medium = "0"^n_medium
            output_medium = "0"^n_medium
        end
        
        # Convert to tensor network
        @timeit to "TNC Conversion" begin
            tnc = convert_to_tnc(circuit_medium; no_input=false, no_output=false, 
                                input=input_medium, output=output_medium)
            light_graf = convert_to_graph(tnc)
        end
        
        # Get communities using different methods
        @timeit to "METIS partitioning" begin
            metis_communities = metis_partition_graph(light_graf, num_communities_medium)
        end
        
        @timeit to "Girvan-Newman" begin
            labeled_light_graf = LabeledGraph(light_graf)
            gn_communities, _, gn_modularity = labelg_to_communitats_between(labeled_light_graf, num_communities_medium)
        end
        
        @timeit to "Fast Greedy" begin
            labeled_light_graf = LabeledGraph(light_graf)
            fg_communities, _, fg_modularity = labelg_to_communitats_fastgreedy(labeled_light_graf)
        end
        
        # Print statistics about communities
        println("\nCommunity size statistics:")
        
        println("METIS ($num_communities_medium communities):")
        metis_sizes = [length(c) for c in metis_communities]
        println("  Min: $(minimum(metis_sizes)), Max: $(maximum(metis_sizes)), Avg: $(sum(metis_sizes)/length(metis_sizes))")
        
        println("Girvan-Newman ($(length(gn_communities)) communities, modularity: $gn_modularity):")
        gn_sizes = [length(c) for c in gn_communities]
        println("  Min: $(minimum(gn_sizes)), Max: $(maximum(gn_sizes)), Avg: $(sum(gn_sizes)/length(gn_sizes))")
        
        println("Fast Greedy ($(length(fg_communities)) communities, modularity: $fg_modularity):")
        fg_sizes = [length(c) for c in fg_communities]
        println("  Min: $(minimum(fg_sizes)), Max: $(maximum(fg_sizes)), Avg: $(sum(fg_sizes)/length(fg_sizes))")
        
        # Save results to file
        output_file_medium = "results_community_comparison_n$(n_medium).txt"
        open(output_file_medium, "w") do f
            println(f, "Circuit: QFT $(n_medium) qubits")
            println(f, "\nCommunity size statistics:")
            
            println(f, "METIS ($num_communities_medium communities):")
            println(f, "  Min: $(minimum(metis_sizes)), Max: $(maximum(metis_sizes)), Avg: $(sum(metis_sizes)/length(metis_sizes))")
            
            println(f, "Girvan-Newman ($(length(gn_communities)) communities, modularity: $gn_modularity):")
            println(f, "  Min: $(minimum(gn_sizes)), Max: $(maximum(gn_sizes)), Avg: $(sum(gn_sizes)/length(gn_sizes))")
            
            println(f, "Fast Greedy ($(length(fg_communities)) communities, modularity: $fg_modularity):")
            println(f, "  Min: $(minimum(fg_sizes)), Max: $(maximum(fg_sizes)), Avg: $(sum(fg_sizes)/length(fg_sizes))")
            
            println(f, "\nTiming Results:")
            show(f, to, allocations=true, sortby=:firstexec)
        end
        println("Results saved to $(output_file_medium)")
    end

    @timeit to "Large Circuit Test" begin
        # Ask if user wants to run a large circuit test
        println("\nDo you want to run a test with a larger circuit (20 qubits)? (y/n)")
        response = readline()
        if lowercase(response) == "y"
            n_large = 20
            num_communities_large = 8
            num_threads_large = 8
            
            @timeit to "Large Circuit Creation" begin
                circuit_large = create_qft_circuit(n_large)
                input_large = "0"^n_large
                output_large = "0"^n_large
            end
            
            @timeit to "Large Circuit Contraction" begin
                Profile.@profile begin
                    try
                        result_large = ComParCPU_METIS(circuit_large, input_large, output_large, num_communities_large)
                        println("\nContraction successful!")
                        println("Result: ", result_large)
                        
                        # Save results to file
                        output_file_large = "results_final.txt"
                        open(output_file_large, "w") do f
                            println(f, "Circuit: QFT $(n_large) qubits")
                            println(f, "Communities: $(num_communities_large)")
                            println(f, "Result: $(result_large)")
                            println(f, "\nTiming Results:")
                            show(f, to, allocations=true, sortby=:firstexec)
                        end
                        println("Results saved to $(output_file_large)")
                    catch e
                        println("Error during contraction: ", e)
                        showerror(stdout, e)
                        println()
                    end
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