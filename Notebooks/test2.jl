include("../src/TensorContraction_OpenMP.jl")

# Set Julia's threading environment variable before running
# This is in addition to OpenMP threads
ENV["JULIA_NUM_THREADS"] = 8

# You might also want to set OpenMP thread count directly
ENV["OMP_NUM_THREADS"] = 8

# Create a circuit
n = 10
circuit = create_qft_circuit(n)

# Run with LLVMOpenMP_jll
input = "0"^n
output = "0"^n
num_threads = 8  # Set to the number of cores you want to use

# Configure the contraction algorithm
num_communities = 4
input = "0"^100
output = "0"^100
convert_to_tnc(circuit; input=input, output=output, decompose=true)

println("Successfully converted to TNC")

try
    # Make sure we're using the OpenMP function with updated LLVMOpenMP_jll
    set_openmp_threads(num_threads)
    println("Confirmed OpenMP threads: ", get_openmp_threads())
    
    result = ComParCPU_OpenMP(circuit, input, output, num_communities, num_threads)
    println("Contraction result: ", result)
    println(result)
catch e
    println("Error during contraction: ", e)
    println("Error type: ", typeof(e))
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end