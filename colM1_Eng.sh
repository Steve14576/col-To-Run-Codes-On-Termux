#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# Script version info
# ==============================================
VERSION="M1.0.Eng"

# ==============================================
# Unified Banner (version box)
# ==============================================
show_banner() {
    echo "┌──────────────────────────────────┐"
    echo "│          col $VERSION            │"
    echo "│   Multi-language Compile & Run   │"
    echo "└──────────────────────────────────┘"
}

# ==============================================
# Display help information
# ==============================================
show_help() {
    show_banner
    echo ""
    echo "📋 Supported languages:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin, Go"
    echo ""
    echo "🔍 Features:"
    echo "   • Termux environment support"
    echo "   • Recursive source file search"
    echo "   • Ctrl+C shows config seed on exit"
    echo ""
    echo "🚀 Quick Start:"
    echo "   ./colM1_Eng.sh [config-seed]"
    echo ""
    echo "⚙️  Config seed options:"
    echo "   f-<source-path>     Set source file directory"
    echo "   t-<output-path>     Set build output directory"
    echo "   op-<mapping>        Set compiler-language mapping"
    echo ""
    echo "🎮 Usage:"
    echo "   <filename>           Run the specified file"
    echo "   <filename> <compiler>  Run with a specific compiler (once)"
    echo "   vls                  List source files with numbers"
    echo "   <number>             Run the file by its listed number"
    echo "   checkavails          Show compiler availability"
    echo "   -h, --help           Show this help"
    echo "   -v, --version        Show version info"
    echo ""
    echo "📝 Examples:"
    echo "   ./colM1_Eng.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   vls"
    echo "   1"
    echo "   checkavails"
    echo "   Ctrl+C (exit and show config seed)"
    echo ""
    echo "💡 Tip: You can also type --help or --version in interactive mode"
    echo ""
    echo "🌐 Current environment language support:"
    echo ""
    # Sort by language name for stable output
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  not installed   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Display version information
# ==============================================
show_version() {
    show_banner
    echo ""
}

# ==============================================
# Trap Ctrl+C: show config seed on exit
# ==============================================
trap 'show_exit_seed; echo -e "\nProgram terminated"; exit 0' SIGINT

# ==============================================
# Utility: format directory path for display
# ==============================================
format_path_for_display() {
    local path="$1"
    
    local full_path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    if [[ "$full_path" == "/" ]]; then
        echo "/"
        return
    fi
    
    full_path=${full_path%/}
    
    local slash_count=$(echo "$full_path" | tr -cd '/' | wc -c)
    
    if [[ $slash_count -le 2 ]]; then
        echo "$full_path"
    else
        local basename=$(basename "$full_path")
        local parent_dir=$(basename "$(dirname "$full_path")")
        local grandparent_dir=$(basename "$(dirname "$(dirname "$full_path")")")
        echo ".../$grandparent_dir/$parent_dir/$basename"
    fi
}

# ==============================================
# Show exit seed (config snapshot)
# ==============================================
show_exit_seed() {
    echo "┌──────────────────────────────────┐"
    echo "│           Config Seed            │"
    echo "│  Use this command to reinit:     │"
    
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    local seed_command="./colM1_Eng.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└───────────────────────────────────"
}

# ==============================================
# Load seed config from command-line arguments
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    
    source_dir=$default_source
    output_dir=$default_output
    op_codes=""
    
    for arg in "${args[@]}"; do
        if [[ $arg == "-h" || $arg == "--help" ]]; then
            show_help
            exit 0
        elif [[ $arg == "-v" || $arg == "--version" ]]; then
            show_version
            exit 0
        elif [[ $arg == f-* ]]; then
            source_dir="${arg#f-}"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
        else
            echo "⚠️  Unknown argument: $arg (ignored)"
        fi
    done
}

# ==============================================
# Internal registry: language-compiler mapping (core config)
# Structure: lang -> "default_compiler:candidate1,candidate2,..."
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
    ["go"]="go:go"
)

# State variables
declare -A lang_default_compiler  # User-set default compiler per language
source_dir=""                     # Source file directory
output_dir=""                     # Build output directory
execute=true                      # Whether to execute after compiling
delete_after=true                 # Whether to delete artifact after running

# ==============================================
# Utility: parse language config
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# Utility: check if a command is installed
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# Utility: get compiler version string
# ==============================================
get_compiler_version() {
    local compiler="$1"
    local version=""
    case "$compiler" in
        gcc|g++|clang|clang++|gfortran)
            version=$("$compiler" --version 2>/dev/null | head -1) ;;
        javac)
            version=$(javac -version 2>&1 | head -1) ;;
        python3|pypy|pypy3)
            version=$("$compiler" --version 2>&1 | head -1) ;;
        bash)
            version=$(bash --version 2>/dev/null | head -1) ;;
        sh)
            version="sh (system default)" ;;
        node)
            version="node $($compiler --version 2>/dev/null)" ;;
        php)
            version=$("$compiler" --version 2>/dev/null | head -1) ;;
        rustc)
            version=$("$compiler" --version 2>/dev/null) ;;
        kotlinc)
            version=$("$compiler" -version 2>&1 | head -1) ;;
        octave)
            version=$("$compiler" --version 2>/dev/null | head -1) ;;
        go)
            version=$("$compiler" version 2>/dev/null) ;;
        *)
            version=$("$compiler" --version 2>/dev/null | head -1) ;;
    esac
    echo "$version"
}

# ==============================================
# Utility: get install hint for a compiler
# ==============================================
get_install_hint() {
    local compiler="$1"
    case "$compiler" in
        python3|pypy|pypy3) echo "pkg install python" ;;
        gcc|g++|clang|clang++) echo "pkg install clang" ;;
        javac) echo "pkg install openjdk-17" ;;
        node) echo "pkg install nodejs" ;;
        php) echo "pkg install php" ;;
        bash|sh) echo "pkg install bash" ;;
        gfortran) echo "pkg install gcc-gfortran" ;;
        rustc) echo "pkg install rust" ;;
        kotlinc) echo "pkg install kotlin" ;;
        octave) echo "pkg install octave" ;;
        go) echo "pkg install golang" ;;
        *) echo "(please install $compiler manually)" ;;
    esac
}

# ==============================================
# Utility: recursively find a file
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth 5 -name "$filename" -type f -print0 2>/dev/null)
    
    # Fallback to common Android storage paths if not found
    if [[ ${#found_files[@]} -eq 0 && ( "$search_dir" == "." || "$search_dir" == "./" ) ]]; then
        local android_paths=(
            "/storage/emulated/0/"
            "/sdcard/"
            "$HOME/storage/shared/"
        )
        
        for android_path in "${android_paths[@]}"; do
            if [[ -d "$android_path" ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$android_path" -maxdepth 3 -name "$filename" -type f -print0 2>/dev/null)
                if [[ ${#found_files[@]} -gt 0 ]]; then
                    break
                fi
            fi
        done
    fi
    
    echo "${found_files[@]}"
}

# ==============================================
# Apply compiler-language pairs (for auto-init)
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })
    
    for op in "${op_list[@]}"; do
        if [[ $op == *-* ]]; then
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Unsupported language '$lang' (ignored)"
                continue
            fi
            
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  Compiler '$compiler' is not supported for language '$lang' (ignored)"
                continue
            fi
            
            lang_default_compiler[$lang]=$compiler
            
            if ! is_installed "$compiler"; then
                echo "⚠️  Note: $compiler is not installed"
                echo "   💡 Suggested install: $(get_install_hint "$compiler")"
            fi
        else
            echo "⚠️  Unknown config entry '$op' (ignored)"
        fi
    done
}

# ==============================================
# Initialization flow
# ==============================================
initialize() {
    local script_dir=$(dirname "$0")
    
    # 1. Configure source directory
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  Source directory does not exist, using default"
        source_dir=$default_source
    fi
    
    # 2. Configure output directory
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  Output directory does not exist, using default"
        output_dir=$default_output
    fi
    
    # 3. Apply default compiler config
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    if [[ -n "$op_codes" ]]; then
        apply_compiler_language_pairs "$op_codes"
    fi
}

# ==============================================
# List source files with numbers
# (Tree pre-order: './' first, then path-lexicographic DFS)
# ==============================================
vls() {
    echo "┌──────────────────────────────────┐"
    echo "│      Source Files in Directory   │"
    echo "└──────────────────────────────────┘"

    local abs_source
    abs_source=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")

    local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt" "*.go")
    local find_args=()
    local first=true
    for ext in "${extensions[@]}"; do
        if $first; then
            find_args+=(-name "$ext"); first=false
        else
            find_args+=(-o -name "$ext")
        fi
    done

    local all_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && all_files+=("$file")
    done < <(find "$abs_source" -maxdepth 5 -mindepth 1 -type f \( "${find_args[@]}" \) 2>/dev/null)

    if [[ ${#all_files[@]} -eq 0 ]]; then
        echo "❌ No supported source files found in directory or subdirectories"
        echo "└───────────────────────────────────"
        echo ""
        return 0
    fi

    # Bucket files by directory
    declare -A _dir_files
    for file in "${all_files[@]}"; do
        local rel="${file#$abs_source/}"
        local dir
        dir=$(dirname "$rel")
        if [[ -z "${_dir_files[$dir]+x}" ]]; then
            _dir_files[$dir]="$file"
        else
            _dir_files[$dir]+=$'\n'"$file"
        fi
    done

    # DFS tree sort: '.' first, then lexicographic
    local sorted_dirs=()
    while IFS= read -r dir; do
        [[ -n "$dir" ]] && sorted_dirs+=("$dir")
    done < <(
        {
            [[ -v "_dir_files[.]" ]] && echo "."
            for dir in "${!_dir_files[@]}"; do
                [[ "$dir" != "." ]] && echo "$dir"
            done | sort
        }
    )

    echo "Found ${#all_files[@]} source file(s):"

    local counter=1
    vls_files=()

    for dir in "${sorted_dirs[@]}"; do
        echo ""
        if [[ "$dir" == "." ]]; then
            echo "  ./"
        else
            echo "  $dir/"
        fi

        while IFS= read -r file; do
            [[ -n "$file" ]] || continue
            local filename
            filename=$(basename "$file")
            printf "    %2d. %s\n" "$counter" "$filename"
            vls_files+=("$file")
            ((counter++))
        done < <(echo "${_dir_files[$dir]}" | sort)
    done

    echo ""
    echo "💡 Enter a file number to run the corresponding file"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Helper: inline-refresh compile status display
# Usage: run_compiler <compiler-command-and-args...>
# ==============================================
run_compiler() {
    local tmp_err="/tmp/_col_err_$$"
    printf "🔨 Compiling..."
    "$@" 2>"$tmp_err"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        printf "\r✅ Compiled successfully\n"
    else
        printf "\r❌ Compilation failed\n"
        cat "$tmp_err"
    fi
    rm -f "$tmp_err"
    return $rc
}

# ==============================================
# Core compile & execute logic
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"  # Optional: user-specified one-time compiler
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    # 1. Check file exists
    if [[ ! -f "$full_path" ]]; then
        echo "❌ Error: file '$full_path' does not exist"
        return 1
    fi
    
    # 2. Detect language from extension
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
        *.go) lang="go" ;;
        *) 
            echo "❌ Error: unsupported file type '$filename'"
            return 1
            ;;
    esac
    
    # 3. Determine compiler to use
    if [[ -n "$custom_compiler" ]]; then
        compiler="$custom_compiler"
        echo "⚠️  Using one-time compiler override: $compiler"
    else
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. Check compiler is installed
    if ! is_installed "$compiler"; then
        echo "❌ Error: compiler '$compiler' is not installed"
        echo "   💡 Suggested install: $(get_install_hint "$compiler")"
        return 1
    fi
    
    # 5. Compile and/or run
    echo "┌──────────────────────────────────┐"
    echo "│  ▶ $filename  [$lang · $compiler]"
    echo "└──────────────────────────────────┘"
    
    local original_dir=$(pwd)
    
    case "$compiler" in
        # Python
        python3|pypy|pypy3)
            "$compiler" "$full_path"
            ;;
        
        # C
        gcc|clang)
            local output_file="${output_dir}/$(basename "$filename" .c)"
            run_compiler "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && "$output_file"
                [[ $delete_after == true ]] && rm -f "$output_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # C++
        g++|clang++)
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            run_compiler "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && "$output_file"
                [[ $delete_after == true ]] && rm -f "$output_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Java
        javac)
            local classname=$(basename "$filename" .java)
            run_compiler javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && (cd "$output_dir" && java "$classname")
                [[ $delete_after == true ]] && rm -f "${output_dir}/${classname}.class"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Shell
        bash|sh)
            "$compiler" "$full_path"
            ;;
        
        # JavaScript
        node)
            "$compiler" "$full_path"
            ;;
        
        # PHP
        php)
            "$compiler" "$full_path"
            ;;
        
        # Fortran
        gfortran)
            local output_file="${output_dir}/$(basename "$filename" .f)"
            case "$filename" in
                *.f90) output_file="${output_dir}/$(basename "$filename" .f90)" ;;
                *.f95) output_file="${output_dir}/$(basename "$filename" .f95)" ;;
                *.f03) output_file="${output_dir}/$(basename "$filename" .f03)" ;;
                *.f08) output_file="${output_dir}/$(basename "$filename" .f08)" ;;
            esac
            run_compiler "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && "$output_file"
                [[ $delete_after == true ]] && rm -f "$output_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Rust
        rustc)
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            run_compiler "$compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && "$output_file"
                [[ $delete_after == true ]] && rm -f "$output_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Kotlin
        kotlinc)
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            run_compiler "$compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && java -jar "$jar_file"
                [[ $delete_after == true ]] && rm -f "$jar_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Octave
        octave)
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        # Go
        go)
            local output_file="${output_dir}/$(basename "$filename" .go)"
            run_compiler "$compiler" build -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                [[ $execute == true ]] && "$output_file"
                [[ $delete_after == true ]] && rm -f "$output_file"
            else
                cd "$original_dir"; return 1
            fi
            ;;
        
        # Unknown compiler
        *)
            echo "❌ Error: unsupported compiler '$compiler'"
            cd "$original_dir"
            return 1
            ;;
    esac
    
    cd "$original_dir"
    return 0
}

# ==============================================
# Display compiler availability
# ==============================================
check_availability() {
    echo "┌──────────────────────────────────┐"
    echo "│      Compiler Availability       │"
    echo "└──────────────────────────────────┘"
    
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local rec_compiler=$(get_default_default "$lang")
        local active_compiler="${lang_default_compiler[$lang]:-$rec_compiler}"
        local candidates=$(get_candidates "$lang")
        
        echo ""
        echo "  ${lang}"
        
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            if [[ "$active_compiler" == "$compiler" ]]; then
                local ptr=">"
            else
                local ptr=" "
            fi
            
            local name_col=$(printf '%-10s' "$compiler")
            if is_installed "$compiler"; then
                local version=$(get_compiler_version "$compiler")
                echo "  ${ptr} ✅ ${name_col}  ${version}"
            else
                local hint=$(get_install_hint "$compiler")
                echo "  ${ptr} ❌ ${name_col}  not installed  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Main interactive interface
# ==============================================
main_interface() {
    vls_files=()
    
    while true; do
        local source_dir_display=$(format_path_for_display "$source_dir")
        read -p "🟢[colM1_Eng] $source_dir_display ❯ " -a input
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
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
                continue
            fi
            
            # Check if input is a number (file index)
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                if [[ ${#vls_files[@]} -eq 0 ]]; then
                    echo "❌ Error: please run 'vls' first to list files"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#vls_files[@]} ]]; then
                    echo "❌ Error: invalid file number (enter a number between 1 and ${#vls_files[@]})"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selected_file="${vls_files[$((selection-1))]}"
                local compiler="${input[1]}"
                echo "📁 Running: $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                echo "└───────────────────────────────────"
                echo ""
                continue
            fi
            
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            # Pre-validate: must have a supported extension
            case "$filename" in
                *.c|*.cpp|*.cxx|*.cc|*.java|*.py|*.sh|*.js|*.php|*.m|*.f|*.f90|*.f95|*.f03|*.f08|*.rs|*.kt|*.go)
                    :
                    ;;
                *)
                    echo "❌ Unknown command or unsupported file type: '$filename'"
                    echo "   💡 Type '--help' for help, or 'vls' to list source files"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                    ;;
            esac
            
            local found_files=($(find_file_recursive "$filename" "$source_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
                echo "❌ Error: file '$filename' not found in '${source_full_path}' or its subdirectories"
                echo "└───────────────────────────────────"
                echo ""
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 Multiple files named '$filename' found:"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 Select file number [number (compiler)]: " -a sel_input
                local selection="${sel_input[0]}"
                local override_compiler="${sel_input[1]}"
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Error: invalid selection"
                    echo "└──────────────────────────────────┘"
                    echo ""
                    continue
                fi
                local selected_file="${found_files[$((selection-1))]}"
                execute_file "$selected_file" "${override_compiler:-$compiler}"
                echo "└───────────────────────────────────"
                echo ""
            else
                execute_file "${found_files[0]}" "$compiler"
                echo "└───────────────────────────────────"
                echo ""
            fi
        fi
    done
}

# ==============================================
# Main entry point
# ==============================================
main() {
    # Load config first to prevent ⚠️ messages mixing with banner
    load_seed_from_args "$@"
    initialize
    
    echo ""
    show_banner
    echo "👋 Welcome to colM1_Eng!"
    echo "   • Type '--help' for help"
    echo "   • Type 'vls' to list source files"
    echo "   • Type 'checkavails' to see compiler status"
    echo "📁 Source dir: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "└───────────────────────────────────"
    echo ""
    
    main_interface
}

# Launch
main "$@"
