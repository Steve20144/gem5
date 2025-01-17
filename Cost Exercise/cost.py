import pandas as pd
import re

def extract_cache_info(benchmark_name):
    """Extract cache sizes and associativities from the benchmark name."""
    match = re.search(r"l1i(\d+)kB_l1iassoc(\d+)_l1d(\d+)kB_l1dassoc(\d+)_l2(\d+)MB_l2assoc(\d+)", benchmark_name)
    if match:
        return {
            "L1i_size_kB": int(match.group(1)),
            "L1i_assoc": int(match.group(2)),
            "L1d_size_kB": int(match.group(3)),
            "L1d_assoc": int(match.group(4)),
            "L2_size_MB": int(match.group(5)),
            "L2_assoc": int(match.group(6)),
        }
    else:
        return {
            "L1i_size_kB": None,
            "L1i_assoc": None,
            "L1d_size_kB": None,
            "L1d_assoc": None,
            "L2_size_MB": None,
            "L2_assoc": None,
        }

def calculate_cost_with_unit(file_path, omega):
    """
    Calculate the cost function using a normalized cost unit (omega).
    
    Parameters:
    - file_path: Path to the input file containing benchmark data.
    - omega: Cost unit for cache sizes and associativities.
    """
    # Load the data into a pandas DataFrame
    df = pd.read_csv(file_path, sep="\t")
    
    # Rename columns for easier access
    df.columns = ["Benchmarks", "CPI", "L1d_miss_rate", "L1i_miss_rate", "L2_miss_rate"]
    
    # Extract cache information from benchmark names
    cache_info = df["Benchmarks"].apply(extract_cache_info)
    cache_info_df = pd.DataFrame(cache_info.tolist())
    
    # Add cache information to the main DataFrame
    df = pd.concat([df, cache_info_df], axis=1)
    
    # Normalize cache sizes and associativity based on omega
    df["L1i_size_cost"] = (df["L1i_size_kB"] * 1) / omega  # Assume 1 kB = omega cost
    df["L1d_size_cost"] = (df["L1d_size_kB"] * 1) / omega
    df["L2_size_cost"] = (df["L2_size_MB"] * 1024) / omega  # Convert MB to kB
    
    df["L1i_assoc_cost"] = df["L1i_assoc"] / omega
    df["L2_assoc_cost"] = df["L2_assoc"] / omega
    
    # Calculate the components of the cost function
    df["M_cache"] = 0.4 * df["L1i_size_cost"] + 0.35 * df["L1d_size_cost"] + 0.25 * df["L2_size_cost"]
    df["A_cache"] = 0.75 * df["L1i_assoc_cost"] + 0.25 * df["L2_assoc_cost"]
    df["Performance"] = 0.7 * df["CPI"] + 0.3 * (0.5 * df["L1d_miss_rate"] + 0.3 * df["L1i_miss_rate"] + 0.2 * df["L2_miss_rate"])
    
    # Calculate the total cost
    df["Cost"] = 0.5 * (0.7 * df["M_cache"] + 0.3 * df["A_cache"]) + 0.5 * df["Performance"]
    
    # Return the full DataFrame
    return df

# Specify the file path and omega
file_path = "optim\\sjeng2\\new\\L1\\Results_sjeng4.txt"  # Replace with your file path if necessary
omega = 10  # Assume omega = 10 as an example; adjust based on literature

# Perform the calculation and display the results
results = calculate_cost_with_unit(file_path, omega)
print(results)

# Optionally save the results to a new file
results.to_csv("calculated_costs_with_omega_sjeng4.csv", index=False)
