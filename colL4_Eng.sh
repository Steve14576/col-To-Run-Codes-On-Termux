#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# Script Version Information
# ==============================================
VERSION="L.4.0.Eng"

# ==============================================
# Display Help Information
# ==============================================
show_help() {
    echo "┌────────────────────────────────────────┐"
    echo "│           colL $VERSION              │"
    echo "│   Multi-Language Compilation Tool     │"
    echo "└────────────────────────────────────────┘"
    echo ""
    echo "📋 Supported Languages:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin"
    echo ""
    echo "🔍 Features:"
    echo "   • Supports Termux environment"
    echo "   • Recursive source file search"
    echo "   • Display configuration seed on Ctrl+C exit"
    echo ""
    echo "🚀 Quick Start:"
    echo "   ./colL4_betterui_en.sh [configuration_seed]"
    echo ""
    echo "⚙️  Configuration Seed Options:"
    echo "   f-<source_path>       Configure source file path"
    echo "   t-<output_path>       Configure compilation output path"
    echo "   op-<mapping>          Configure compiler-language mapping"
    echo ""
    echo "🎮 Usage:"
    echo "   <filename>            Run specified file"
    echo "   <filename> <compiler> Run with specified compiler"
    echo "   vls                   List source files and index them"
    echo "   <index>               Run file by index number"
    echo "   checkavails           Show compiler availability"
    echo "   -h, --help            Display help information"
    echo "   -v, --version         Display version information"
    echo ""
    echo "📝 Examples:"
    echo "   ./colL4_betterui_en.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   vls"
    echo "   1"
    echo "   checkavails"
    echo "   Ctrl+C (Exit and display configuration seed)"
    echo ""
    echo "💡 Tip: You can also input --help or --version in interactive mode"
}

# ==============================================
# Display Version Information
# ==============================================
show_version() {
    echo "┌─────────────────────────────┐"
    echo "│   colL Multi-Language Tool  │"
    echo "│      (Lightweight Edition)  │"
    echo "│           v$VERSION           │"
    echo "└─────────────────────────────┘"
}

# ==============================================
# Trap Ctrl+C Signal, Display Configuration Seed on Exit
# ==============================================
trap 'show_exit_seed; echo -e "\nProgram terminated"; exit 0' SIGINT

# ==============================================
# Utility Function: Format Directory Path for Display
# ==============================================
format_path_for_display() {
    local path="$1"
    
    # Get the full path
    local full_path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    # Handle root directory
    if [[ "$full_path" == "/" ]]; then
        echo "/"
        return
    fi
    
    # Remove trailing slash
    full_path=${full_path%/}
    
    # Count slashes to determine depth
    local slash_count=$(echo "$full_path" | tr -cd '/' | wc -c)
    
    if [[ $slash_count -le 2 ]]; then
        # Shallow path, show as is
        echo "$full_path"
    else
        # Deep path, extract last 3 components
        local basename=$(basename "$full_path")
        local parent_dir=$(basename "$(dirname "$full_path")")
        local grandparent_dir=$(basename "$(dirname "$(dirname "$full_path")")")
        echo ".../$grandparent_dir/$parent_dir/$basename"
    fi
}

# ==============================================
# Display Exit Seed Information
# ==============================================
show_exit_seed() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│    Configuration Seed       │"
    echo "│ Use this command next time: │"
    
    # Collect current configuration operation codes
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    # Build seed command
    local seed_command="./colL4_betterui_en.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└─────────────────────────────┘"
}

# ==============================================
# Load Seed Configuration from Command Line Arguments
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    
    # Initialize paths to default values
    source_dir=$default_source
    output_dir=$default_output
    op_codes=""
    
    # Parse arguments
    for arg in "${args[@]}"; do
        if [[ $arg == "-h" || $arg == "--help" ]]; then
            show_help
            exit 0
        elif [[ $arg == "-v" || $arg == "--version" ]]; then
            show_version
            exit 0
        elif [[ $arg == f-* ]]; then
            source_dir="${arg#f-}"
            echo "📁 Source file path: $source_dir (supports recursive search)"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
            echo "📂 Compilation output path: $output_dir"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
            echo "⚙️  Compiler mapping: $op_codes"
        else
            echo "⚠️  Unknown argument: $arg (ignored)"
        fi
    done
}

# ==============================================
# Language-Compiler Configuration Mapping Table (Core Configuration)
# Structure: Language -> [Default Compiler, [Alternative Compiler List...]]
# ==============================================
declare -A language_config=(
    ["c"]="clang:gcc,clang"
    ["cpp"]="g++:g++,clang++"
    ["java"]="javac:javac"
    ["python"]="python3:python3,pypy,pypy3"
    ["shell"]="bash:bash,sh"
    ["javascript"]="node:node"
    ["php"]="php:php"
    ["octave"]="octave:octave"
    ["fortran"]="gfortran:gfortran"
    ["rust"]="rustc:rustc"
    ["kotlin"]="kotlinc:kotlinc"
)

# State variables
declare -A lang_default_compiler  # Default compiler for each language set by user
source_dir=""                     # Source file path
output_dir=""                     # Compilation output path
execute=true                      # Whether to execute after compilation
delete_after=true                 # Whether to delete output after running
declare -A extension_commands     # Extension command dictionary (reserved but unused)
declare -A extension_files        # Extension name to filename mapping (reserved but unused)

# ==============================================
# Utility Function: Parse Language Configuration
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# Utility Function: Check if Command is Installed
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# Utility Function: Recursively Find Files
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    # Search for files in source directory and subdirectories
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -name "$filename" -type f -print0 2>/dev/null)
    
    # If not found in current search directory, try Android storage paths
    if [[ ${#found_files[@]} -eq 0 && "$search_dir" == .* ]]; then
        # Try common Android storage locations
        local android_paths=(
            "/storage/emulated/0/"
            "/sdcard/"
            "$HOME/storage/shared/"
        )
        
        for android_path in "${android_paths[@]}"; do
            if [[ -d "$android_path" ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$android_path" -name "$filename" -type f -print0 2>/dev/null)
                if [[ ${#found_files[@]} -gt 0 ]]; then
                    break
                fi
            fi
        done
    fi
    
    # Return search results
    echo "${found_files[@]}"
}

# ==============================================
# Apply Compiler-Language Mappings (for automatic initialization)
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })  # Split multiple mappings by comma
    
    for op in "${op_list[@]}"; do
        # Check for path configuration parameters
        if [[ $op == f-* ]]; then
            source_dir="${op#f-}"
            echo "📁 Source file path set: $source_dir"
        elif [[ $op == t-* ]]; then
            output_dir="${op#t-}"
            echo "📂 Compilation output path set: $output_dir"
        # Handle compiler-language mappings
        elif [[ $op == *-* ]]; then
            # Parse compiler-language pair
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            # Validate language support
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Unsupported language '$lang' (ignored)"
                continue
            fi
            
            # Validate compiler is in language candidate list
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  Compiler '$compiler' not supported for $lang language (ignored)"
                continue
            fi
            
            # Apply configuration
            lang_default_compiler[$lang]=$compiler
            echo "✅ ${lang} compiler set to: $compiler"
            
            # Check if installation prompt is needed
            if ! is_installed "$compiler"; then
                echo "⚠️  Warning: $compiler not installed"
                case "$compiler" in
                    python3|pypy|pypy3) echo "   💡 Suggested install: pkg install python" ;;
                    gcc|g++|clang|clang++) echo "   💡 Suggested install: pkg install clang" ;;
                    javac) echo "   💡 Suggested install: pkg install openjdk-17" ;;
                    node) echo "   💡 Suggested install: pkg install nodejs" ;;
                    php) echo "   💡 Suggested install: pkg install php" ;;
                    bash|sh) echo "   💡 Suggested install: pkg install bash" ;;
                    gfortran) echo "   💡 Suggested install: pkg install gcc-gfortran" ;;
                    rustc) echo "   💡 Suggested install: pkg install rust" ;;
                    kotlinc) echo "   💡 Suggested install: pkg install kotlin" ;;
                    octave) echo "   💡 Suggested install: pkg install octave" ;;
                esac
            fi
        else
            echo "⚠️  Unknown configuration '$op' (ignored)"
        fi
    done
}

# ==============================================
# Initialize Configuration Process
# ==============================================
initialize() {
    # Get script directory as default path
    local script_dir=$(dirname "$0")
    
    # 1. Configure source file path
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    # Handle relative paths
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  Source file path does not exist, using default path"
        source_dir=$default_source
    fi
    
    # 2. Configure compilation output path
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    # Handle relative paths
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  Compilation output path does not exist, using default path"
        output_dir=$default_output
    fi
    
    # 3. Apply default compiler configuration
    # First set all languages to default recommendations
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    # Apply compiler-language mappings
    if [[ -n "$op_codes" ]]; then
        echo -e "\n🔧 Applying compiler-language mapping configuration..."
        apply_compiler_language_pairs "$op_codes"
    fi
    
    echo -e "\n✅ Initialization complete!"
    
    # Display full paths of script location and source directory
    local script_full_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
    echo "📄 Script location: $script_full_path"
    echo "📁 Source directory: $source_full_path"
}

# ==============================================
# List Source Files in Current Directory with Index Numbers
# ==============================================
vls() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│   Current Directory Files   │"
    echo "└─────────────────────────────┘"
    
    # Store found file paths
    local found_files=()
    
    # Define supported file extensions
    local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
    
    # Search for files in source directory and subdirectories
    for ext in "${extensions[@]}"; do
        while IFS= read -r -d '' file; do
            found_files+=("$file")
        done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
    done
    
    # If no files found
    if [[ ${#found_files[@]} -eq 0 ]]; then
        echo "❌ No supported source files found in current directory or subdirectories"
        echo "└─────────────────────────────┘"
        return 0
    fi
    
    # Display file list with index numbers
    echo "Found ${#found_files[@]} source files:"
    echo ""
    for i in "${!found_files[@]}"; do
        local filename=$(basename "${found_files[$i]}")
        local filepath="${found_files[$i]}"
        printf "  %2d. %s\n" $((i+1)) "$filename"
    done
    echo ""
    echo "💡 Input file index number to run the corresponding file"
    echo "└─────────────────────────────┘"
    
    # Store file list in global array for later use
    vls_files=("${found_files[@]}")
}

# ==============================================
# Core Compilation Execution Logic
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"  # Optional: user-specified compiler for single run
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    # 1. Check if file exists
    if [[ ! -f "$full_path" ]]; then
        echo "❌ Error: File '$full_path' does not exist"
        return 1
    fi
    
    # 2. Determine language by file extension
    case "$filename" in
        *.c) lang="c" ;;
        *.cpp|*.cxx|*.cc) lang="cpp" ;;
        *.java) lang="java" ;;
        *.py) lang="python" ;;
        *.sh) lang="shell" ;;
        *.js) lang="javascript" ;;
        *.php) lang="php" ;;
        *.m) lang="octave" ;;
        *.f|*.f90|*.f95|*.f03|*.f08) lang="fortran" ;;
        *.rs) lang="rust" ;;
        *.kt) lang="kotlin" ;;
        *) 
            echo "❌ Error: Unsupported file type '$filename'"
            return 1
            ;;
    esac
    
    # 3. Determine which compiler to use
    if [[ -n "$custom_compiler" ]]; then
        # Prioritize user-specified compiler
        compiler="$custom_compiler"
        echo "⚠️  Using temporary compiler: $compiler"
    else
        # Use default compiler for this language
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. Check if compiler is installed
    if ! is_installed "$compiler"; then
        echo "❌ Error: Compiler '$compiler' is not installed"
        case "$compiler" in
            python3|pypy|pypy3) echo "   💡 Suggested install: pkg install python" ;;
            gcc|g++|clang|clang++) echo "   💡 Suggested install: pkg install clang" ;;
            javac) echo "   💡 Suggested install: pkg install openjdk-17" ;;
            node) echo "   💡 Suggested install: pkg install nodejs" ;;
            php) echo "   💡 Suggested install: pkg install php" ;;
            bash|sh) echo "   💡 Suggested install: pkg install bash" ;;
            gfortran) echo "   💡 Suggested install: pkg install gcc-gfortran" ;;
            rustc) echo "   💡 Suggested install: pkg install rust" ;;
            kotlinc) echo "   💡 Suggested install: pkg install kotlin" ;;
            octave) echo "   💡 Suggested install: pkg install octave" ;;
        esac
        return 1
    fi
    
    # 5. Execute compilation/run
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│     Executing $filename     │"
    echo "│ Language: $lang | Compiler: $compiler │"
    echo "└─────────────────────────────┘"
    
    # Save current directory
    local original_dir=$(pwd)
    
    # Execute appropriate compile/run command
    case "$compiler" in
        # Python series
        python3|pypy|pypy3)
            echo "🚀 Running Python script..."
            "$compiler" "$full_path"
            ;;
        
        # C series
        gcc|clang)
            local output_file="${output_dir}/$(basename "$filename" .c)"
            echo "🔨 Compiling C file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Compilation output deleted: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # C++ series
        g++|clang++)
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            echo "🔨 Compiling C++ file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Compilation output deleted: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Java
        javac)
            local classname=$(basename "$filename" .java)
            echo "🔨 Compiling Java file..."
            javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: ${output_dir}/${classname}.class"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    (cd "$output_dir" && java "$classname")
                    if [[ $delete_after == true ]]; then
                        rm -f "${output_dir}/${classname}.class"
                        echo "🗑️  Compilation output deleted: ${classname}.class"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Shell
        bash|sh)
            echo "🚀 Running Shell script..."
            "$compiler" "$full_path"
            ;;
        
        # JavaScript
        node)
            echo "🚀 Running JavaScript file..."
            "$compiler" "$full_path"
            ;;
        
        # PHP
        php)
            echo "🚀 Running PHP script..."
            "$compiler" "$full_path"
            ;;
        
        # Fortran
        gfortran)
            local output_file="${output_dir}/$(basename "$filename" .f)"
            # Handle different Fortran extensions
            case "$filename" in
                *.f90) output_file="${output_dir}/$(basename "$filename" .f90)" ;;
                *.f95) output_file="${output_dir}/$(basename "$filename" .f95)" ;;
                *.f03) output_file="${output_dir}/$(basename "$filename" .f03)" ;;
                *.f08) output_file="${output_dir}/$(basename "$filename" .f08)" ;;
            esac
            echo "🔨 Compiling Fortran file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Compilation output deleted: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Rust
        rustc)
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            echo "🔨 Compiling Rust file..."
            "$compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Compilation output deleted: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Kotlin
        kotlinc)
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            echo "🔨 Compiling Kotlin file..."
            "$compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $jar_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    java -jar "$jar_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$jar_file"
                        echo "🗑️  Compilation output deleted: $jar_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Octave
        octave)
            echo "🚀 Running Octave script..."
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        # Unknown compiler
        *)
            echo "❌ Error: Unsupported compiler '$compiler'"
            cd "$original_dir"  # Return to original directory
            return 1
            ;;
    esac
    
    # Return to original directory
    cd "$original_dir"
    
    echo "┌─────────────────────────────┐"
    echo "│      Execution Complete     │"
    echo "└─────────────────────────────┘"
    return 0
}

# ==============================================
# Display Compiler Availability Information
# ==============================================
check_availability() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│ Compiler Availability Check │"
    echo "└─────────────────────────────┘"
    
    for lang in "${!language_config[@]}"; do
        local default_compiler=$(get_default_default "$lang")
        local candidates=$(get_candidates "$lang")
        echo ""
        echo "🔷 $lang language available compilers:"
        echo "   Default compiler: $default_compiler"
        
        # Check each candidate compiler
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            local status=""
            if is_installed "$compiler"; then
                status="✅ Installed"
            else
                status="❌ Not installed"
            fi
            
            # Check if this is the currently used compiler for this language
            if [[ "${lang_default_compiler[$lang]}" == "$compiler" ]]; then
                status="$status [In use]"
            fi
            
            echo "   • $compiler - $status"
        done
    done
    echo ""
    echo "└─────────────────────────────┘"
}

# ==============================================
# Main Interactive Interface
# ==============================================
main_interface() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│      Main Interface         │"
    echo "└─────────────────────────────┘"
    echo "📝 Usage Instructions:"
    echo "   • Input filename (and compiler) to execute once"
    echo "   • Input 'vls' to view list of source files"
    echo "   • Input file index number to run directly"
    echo "   • Press Ctrl+C to exit and display configuration seed"
    echo "└─────────────────────────────┘"
    
    # Global array to store files listed by vls command
    local vls_files=()
    
    while true; do
        # Get source directory for display (last 2 levels)
        local source_dir_display=$(format_path_for_display "$source_dir")
        read -p "🟢[colL] $source_dir_display ❯ " -a input
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
            # Check for special commands
            if [[ "${input[0]}" == "-h" || "${input[0]}" == "--help" ]]; then
                show_help
                continue
            elif [[ "${input[0]}" == "-v" || "${input[0]}" == "--version" ]]; then
                show_version
                continue
            elif [[ "${input[0]}" == "checkavails" ]]; then
                check_availability
                continue
            elif [[ "${input[0]}" == "vls" ]]; then
                vls
                # Update vls_files array for numeric input
                vls_files=()
                local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
                for ext in "${extensions[@]}"; do
                    while IFS= read -r -d '' file; do
                        vls_files+=("$file")
                    done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
                done
                continue
            fi
            
            # Check for numeric input (file index)
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                # Check if file list exists
                if [[ ${#vls_files[@]} -eq 0 ]]; then
                    echo "❌ Error: Please run 'vls' command first to view file list"
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#vls_files[@]} ]]; then
                    echo "❌ Error: Invalid file index (please input number between 1-${#vls_files[@]})"
                    continue
                fi
                
                local selected_file="${vls_files[$((selection-1))]}"
                local compiler="${input[1]}"  # Optional compiler parameter
                echo "📁 Running file: $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                continue
            fi
            
            # Parse user input
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            # Recursively find file
            local found_files=($(find_file_recursive "$filename" "$source_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                # Show full path in error message
                local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
                echo "❌ Error: File '$filename' not found in '${source_full_path}' or subdirectories"
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 Found multiple files named '$filename':"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 Select file index to execute: " selection
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Error: Invalid index"
                    continue
                fi
                local selected_file="${found_files[$((selection-1))]}"
                execute_file "$selected_file" "$compiler"
            else
                execute_file "${found_files[0]}" "$compiler"
            fi
        fi
    done
}

# ==============================================
# Main Function
# ==============================================
main() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        colL v$VERSION         │"
    echo "│ Multi-Language Compile Tool │"
    echo "└─────────────────────────────┘"
    echo "👋 Welcome to colL!"
    echo "   • Input '--help' for help information"
    echo "   • Input 'vls' to view source file list"
    echo "   • Input 'checkavails' to check compiler status"
    echo "└─────────────────────────────┘"
    
    # Load seed configuration from command line arguments
    load_seed_from_args "$@"
    
    # Initialize configuration
    initialize
    
    # Enter main interface
    main_interface
}

# Start program
main "$@"
