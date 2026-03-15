#!/data/data/com.termux/files/usr/bin/bash
# [COL_SEED]

# ==============================================
# Script Version Info
# ==============================================
VERSION="M1.1.Eng"

# ==============================================
# Unified Banner (Version Box)
# ==============================================
show_banner() {
    echo "┌──────────────────────────────────┐"
    echo "│          col $VERSION            │"
    echo "│   Multi-Language Build & Run Tool │"
    echo "└──────────────────────────────────┘"
}

# ==============================================
# Display Help Information
# ==============================================
show_help() {
    show_banner
    echo ""
    echo "📋 Supported Languages:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin, Go"
    echo ""
    echo "🔍 Features:"
    echo "   • Termux environment support"
    echo "   • Recursive source file search"
    echo "   • Show config seed on Ctrl+C exit"
    echo ""
    echo "🚀 Quick Start:"
    echo "   ./colM1_Eng.sh [config seed]"
    echo ""
    echo "⚙️  Config Seed Options:"
    echo "   f-<source path>      Set source file path"
    echo "   t-<output path>      Set build output path"
    echo "   op-<mapping>         Set compiler-language mapping"
    echo ""
    echo "🎮 Usage:"
    echo "   <filename>           Run specified file"
    echo "   <filename> <compiler> Run with specific compiler"
    echo "   num                  List source files with numbers"
    echo "   <number>             Run file by number"
    echo "   vcd <path>          Set virtual target directory (can point outside ~/)"
    echo "   vcd -                Clear virtual directory"
    echo "   vcd                  View current virtual directory"
    echo "   vls [args]          Run ls in virtual directory"
    echo "   status               Current status overview (paths + compiler availability)"
    echo "   save                 Save current config to built-in seed"
    echo "   reset                Clear built-in seed, return to defaults"
    echo "   -h, --help           Show help information"
    echo "   -v, --version        Show version information"
    echo ""
    echo "📝 Examples:"
    echo "   ./colM1_Eng.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   num"
    echo "   1"
    echo "   status"
    echo "   save"
    echo "   reset"
    echo "   Ctrl+C (exit and show config seed)"
    echo ""
    echo "💡 Tip: You can also input --help or --version in interactive mode"
    echo ""
    echo "🌐 Current Environment Language Support:"
    echo ""
    # Display sorted by language name to avoid random order
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        # Prefer compiler set in current session, otherwise use built-in default
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  Not Installed   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Display Version Information
# ==============================================
show_version() {
    show_banner
    echo ""
}

# ==============================================
# Capture Ctrl+C signal, show current config seed on exit
# ==============================================
trap 'show_exit_seed; echo -e "\nProgram terminated"; exit 0' SIGINT

# ==============================================
# Utility: Format directory path for display
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
    echo "┌──────────────────────────────────┐"
    echo "│         Config Seed              │"
    echo "│  Use this command to init next:  │"
    
    # Collect current config opcodes
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    # Build seed command
    local seed_command="./colM1_Eng.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└───────────────────────────────────"
}

# ==============================================
# Load seed from command line arguments
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    
    # Initialize paths to defaults
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
# Seed Persistence: Incremental Apply/Load/Save/Reset
# ==============================================

# Incrementally apply seed fragment (does not reset existing config)
apply_seed_fragment() {
    for arg in "$@"; do
        if [[ "$arg" == f-* ]]; then
            source_dir="${arg#f-}"
        elif [[ "$arg" == t-* ]]; then
            output_dir="${arg#t-}"
        elif [[ "$arg" == op-* ]]; then
            op_codes="${arg#op-}"
            apply_compiler_language_pairs "$op_codes"
        fi
    done
}

# Load config from built-in # [COL_SEED] line in script
load_stored_seed() {
    local script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local stored
    stored=$(grep '^# \[COL_SEED\]' "$script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')
    if [[ -n "$stored" ]]; then
        apply_seed_fragment $stored
        return 0
    fi
    return 1
}

# Save current config to built-in seed in script
save_seed() {
    local script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local seed_str="f-${source_dir} t-${output_dir}"
    # Only include non-default compiler mappings
    local op_parts=()
    for lang in "${!lang_default_compiler[@]}"; do
        local compiler="${lang_default_compiler[$lang]}"
        local default_compiler
        default_compiler=$(get_default_default "$lang")
        if [[ "$compiler" != "$default_compiler" ]]; then
            op_parts+=("${compiler}-${lang}")
        fi
    done
    if [[ ${#op_parts[@]} -gt 0 ]]; then
        seed_str+=" op-$(IFS=,; echo "${op_parts[*]}")"
    fi
    sed -i "s|^# \[COL_SEED\].*|# [COL_SEED] ${seed_str}|" "$script_path"
    echo "   └─ 💾 Seed saved: $seed_str"
    echo ""
}

# Clear built-in seed in script, return to defaults
reset_seed() {
    local script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    sed -i "s|^# \[COL_SEED\].*|# [COL_SEED]|" "$script_path"
    echo "   └─ 🔄 Seed cleared"
    echo ""
}

# ==============================================
# Startup Seed Input mini-REPL
# ==============================================
seed_startup_repl() {
    local script_path
    script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local stored
    stored=$(grep '^# \[COL_SEED\]' "$script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')

    echo "┌───────────────────────────────────"
    echo "│  ⚙️ Seed Config  (Press Enter twice to skip)"
    if [[ -n "$stored" ]]; then
        echo "│  💾 Last record: $stored"
    else
        echo "│  💾 Last record: (empty)"
    fi
    echo "│  📝 Format: f-<path>  t-<path>  op-<compiler>-<language>  "
    echo "│           [add save to save seed]  [add reset to reset seed to default]"
    echo "└───────────────────────────────────"
    echo ""

    local empty_count=0
    local _rlines=0  # Track REPL lines printed (including empty lines)
    while true; do
        read -rp "  [Seed] ❱ " seed_input
        (( _rlines++ ))

        if [[ -z "$seed_input" ]]; then
            (( empty_count++ ))
            if [[ $empty_count -ge 2 ]]; then
                break
            fi
            echo "      (Press Enter again to enter)"
            (( _rlines++ ))
            continue
        fi

        empty_count=0

        # reset
        if [[ "$seed_input" == "reset" ]]; then
            reset_seed
            (( _rlines += 2 ))
            local script_dir
            script_dir=$(dirname "$0")
            source_dir="$script_dir"
            output_dir="$script_dir"
            continue
        fi

        # save standalone = save current full config
        if [[ "$seed_input" == "save" ]]; then
            save_seed
            (( _rlines += 2 ))
            continue
        fi

        # Check for save suffix
        local do_save=false
        local seed_part="$seed_input"
        if [[ "$seed_input" == *" save" ]]; then
            do_save=true
            seed_part="${seed_input% save}"
        fi

        # Incrementally apply seed fragment
        apply_seed_fragment $seed_part

        if $do_save; then
            save_seed
            (( _rlines += 2 ))
        fi
    done
    # Move up _rlines+7 (header box 6 lines + empty line 1), clear to end of screen
    printf '\033[%dA\033[J' "$(( _rlines + 7 ))"
    echo "└─ ⚙️ Config completed  f-${source_dir} t-${output_dir}"
    echo ""
    echo "📂 Source: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "🛠️ Output: $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Internal: Language-Compiler Mapping Table (Core Config)
# Structure: language -> [default compiler, [alternative compilers...]]
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
declare -A lang_default_compiler  # User-set default compiler for each language
source_dir=""                     # Source file path
output_dir=""                     # Build output path
execute=true                      # Execute after compile
delete_after=true                 # Delete output after run
VTARGET=""                        # v-series virtual target directory (can be outside ~/)

# ==============================================
# Utility: Parse language config
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# Utility: Check if command is installed
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# Utility: Get compiler version string
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
# Utility: Get compiler install hint command
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
        *) echo "(Please manually install $compiler)" ;;
    esac
}

# ==============================================
# Utility: Recursively find file
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    # Find file in source directory and subdirectories
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth 5 -name "$filename" -type f -print0 2>/dev/null)
    
    # If not found in current search dir, try Android storage paths
    # Only enabled when source_dir is explicit relative path "." or "./" to avoid scanning entire storage
    if [[ ${#found_files[@]} -eq 0 && ( "$search_dir" == "." || "$search_dir" == "./" ) ]]; then
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
                done < <(find "$android_path" -maxdepth 3 -name "$filename" -type f -print0 2>/dev/null)
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
# Apply Compiler-Language Mapping (for auto-initialization)
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })  # Split multiple mappings by comma
    
    for op in "${op_list[@]}"; do
        # Handle compiler-language mappings
        if [[ $op == *-* ]]; then
            # Parse compiler-language pair
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            # Verify language is supported
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Unsupported language '$lang' (ignored)"
                continue
            fi
            
            # Verify compiler is in candidate list for this language
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  Compiler '$compiler' not supported for $lang language (ignored)"
                continue
            fi
            
            # Apply config
            lang_default_compiler[$lang]=$compiler
            
            # Check if install hint needed
            if ! is_installed "$compiler"; then
                echo "⚠️  Note: $compiler not installed"
                echo "   💡 Suggested install: $(get_install_hint "$compiler")"
            fi
        else
            echo "⚠️  Unknown config '$op' (ignored)"
        fi
    done
}

# ==============================================
# Initialization Process
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
        echo "⚠️  Source path does not exist, using default path"
        source_dir=$default_source
    fi
    
    # 2. Configure build output path
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    # Handle relative paths
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  Output path does not exist, using default path"
        output_dir=$default_output
    fi
    
    # 3. Apply default compiler config
    # First set all languages to default recommendation
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    # Apply compiler-language mappings
    if [[ -n "$op_codes" ]]; then
        apply_compiler_language_pairs "$op_codes"
    fi
}

# ==============================================
# List source files with numbers (tree pre-order: './' first, then dict order = DFS pre-order)
# ==============================================
num() {
    echo "┌──────────────────────────────────┐"
    echo "│      Source File List            │"
    echo "└──────────────────────────────────┘"

    local abs_source
    local _num_base="${VTARGET:-$source_dir}"
    abs_source=$(realpath "$_num_base" 2>/dev/null || echo "$_num_base")

    # Build find extension filter arguments
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

    # Collect all files with one find
    local all_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && all_files+=("$file")
    done < <(find "$abs_source" -maxdepth 5 -mindepth 1 -type f \( "${find_args[@]}" \) 2>/dev/null)

    if [[ ${#all_files[@]} -eq 0 ]]; then
        echo "❌ No supported source files found in current directory and subdirectories"
        echo "└───────────────────────────────────"
        echo ""
        return 0
    fi

    # Bucket by directory: _dir_files[dir] = newline-separated file absolute paths
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

    # DFS tree sort: '.' first, then path dict order (parent naturally before child)
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

    echo "Found ${#all_files[@]} source files:"

    local counter=1
    num_files=()

    for dir in "${sorted_dirs[@]}"; do
        echo ""
        if [[ "$dir" == "." ]]; then
            echo "  ./"
        else
            echo "  $dir/"
        fi

        # Sort files within directory by filename
        while IFS= read -r file; do
            [[ -n "$file" ]] || continue
            local filename
            filename=$(basename "$file")
            printf "    %2d. %s\n" "$counter" "$filename"
            num_files+=("$file")
            ((counter++))
        done < <(echo "${_dir_files[$dir]}" | sort)
    done

    echo ""
    echo "💡 Enter file number to run corresponding file"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# v-series: Virtual Directory Management (Permission Crossing Layer)
# ==============================================

# vcd: Set / View / Clear virtual target directory
vcd() {
    local target="${1:-}"

    if [[ -z "$target" || "$target" == "-" ]]; then
        # No args / vcd - : go home (clear VTARGET)
        VTARGET=""
        echo "└─ 🏠 Back to source: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
        echo ""
        return 0
    fi

    # Relative paths based on VTARGET (or source_dir)
    if [[ "$target" != /* ]]; then
        local _base="${VTARGET:-$source_dir}"
        target="$_base/$target"
    fi

    # Verify path is readable
    if [[ ! -d "$target" ]]; then
        echo "❌ Path does not exist or is not a directory: '$target'"
        echo "└───────────────────────────────────"
        echo ""
        return 1
    fi

    VTARGET=$(realpath "$target" 2>/dev/null || echo "$target")
    echo "└─ 🔗 Virtual directory set: $VTARGET"
    echo ""
    return 0
}

# vls: Execute ls in virtual directory (supports passing ls arguments)
vls() {
    local target="${VTARGET:-$source_dir}"
    ls "$@" "$target"
}

# ==============================================
# Helper: Inline refresh display compile status
# Usage: run_compiler <compiler command and args...>
# ==============================================
run_compiler() {
    local tmp_err="/tmp/_col_err_$$"
    printf "🔨 Compiling..."
    "$@" 2>"$tmp_err"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        printf "\r✅ Compile successful\n"
    else
        printf "\r❌ Compile failed\n"
        cat "$tmp_err"
    fi
    rm -f "$tmp_err"
    return $rc
}

# ==============================================
# Core Compile & Execute Logic
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
    
    # 2. Determine language by extension
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
            echo "❌ Error: Unsupported file type '$filename'"
            return 1
            ;;
    esac
    
    # 3. Determine compiler to use
    if [[ -n "$custom_compiler" ]]; then
        # Prefer user-specified compiler for single run
        compiler="$custom_compiler"
        echo "⚠️  Using compiler temporarily: $compiler"
    else
        # Use default compiler for this language
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. Check if compiler is installed
    if ! is_installed "$compiler"; then
        echo "❌ Error: Compiler '$compiler' not installed"
        echo "   💡 Suggested install: $(get_install_hint "$compiler")"
        return 1
    fi
    
    # 5. Execute compile and run
    echo "┌──────────────────────────────────┐"
    echo "│  ▶ $filename  [$lang · $compiler]"
    echo "└──────────────────────────────────┘"
    
    # Save current directory
    local original_dir=$(pwd)
    
    # Execute corresponding compile/run command
    case "$compiler" in
        # Python series
        python3|pypy|pypy3)
            "$compiler" "$full_path"
            ;;
        
        # C series
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
        
        # C++ series
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
            echo "❌ Error: Unsupported compiler '$compiler'"
            cd "$original_dir"  # Return to original directory
            return 1
            ;;
    esac
    
    # Return to original directory
    cd "$original_dir"
    return 0
}

# ==============================================
# Current Status Overview (formerly checkavails)
# ==============================================
status() {
    echo "┌──────────────────────────────────┐"
    echo "│           Status                 │"
    echo "└──────────────────────────────────┘"
    echo ""
    echo "  📂 Source:    $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "  🛠️ Output:  $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    [[ -n "$VTARGET" ]] && echo "  🔗 Virtual:  $VTARGET"
    local script_path
    script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local stored
    stored=$(grep '^# \[COL_SEED\]' "$script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')
    if [[ -n "$stored" ]]; then
        echo "  💾 Built-in Seed:  $stored"
    else
        echo "  💾 Built-in Seed:  (empty)"
    fi
    echo ""

    # Sort by language name for stable output
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local rec_compiler=$(get_default_default "$lang")
        local active_compiler="${lang_default_compiler[$lang]:-$rec_compiler}"
        local candidates=$(get_candidates "$lang")
        
        echo ""
        echo "  ${lang}"
        
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            # > marks active compiler, pure ASCII single char ensures column alignment
            if [[ "$active_compiler" == "$compiler" ]]; then
                local ptr=">"
            else
                local ptr=" "
            fi
            
            # emoji outside printf to avoid double-width char alignment issues
            # Column structure: 2spaces + ptr(1col) + 1space + emoji(2cols) + 1space + compiler name(10cols) + 2spaces + info
            local name_col=$(printf '%-10s' "$compiler")
            if is_installed "$compiler"; then
                local version=$(get_compiler_version "$compiler")
                echo "  ${ptr} ✅ ${name_col}  ${version}"
            else
                local hint=$(get_install_hint "$compiler")
                echo "  ${ptr} ❌ ${name_col}  Not Installed  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Main Interactive Interface
# ==============================================
main_interface() {
    # Global array to store files listed by num command
    num_files=()
    
    while true; do
        # Prompt: use 🔵+🔗 when VTARGET is set
        if [[ -n "$VTARGET" ]]; then
            local _prompt_dir=$(format_path_for_display "$VTARGET")
            read -p "🔵[colM1_Eng]🔗 $_prompt_dir ❯ " -a input
        else
            local _prompt_dir=$(format_path_for_display "$source_dir")
            read -p "🟢[colM1_Eng] $_prompt_dir ❯ " -a input
        fi
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
            # Check special commands
            if [[ "${input[0]}" == "-h" || "${input[0]}" == "--help" ]]; then
                show_help
                continue
            elif [[ "${input[0]}" == "-v" || "${input[0]}" == "--version" ]]; then
                show_version
                continue
            elif [[ "${input[0]}" == "checkavails" || "${input[0]}" == "status" ]]; then
                status
                continue
            elif [[ "${input[0]}" == "save" ]]; then
                save_seed
                continue
            elif [[ "${input[0]}" == "reset" ]]; then
                reset_seed
                local script_dir
                script_dir=$(dirname "$0")
                source_dir="$script_dir"
                output_dir="$script_dir"
                continue
            elif [[ "${input[0]}" == "vcd" ]]; then
                vcd "${input[1]:-}"
                continue
            elif [[ "${input[0]}" == "vls" ]]; then
                vls "${input[@]:1}"
                continue
            elif [[ "${input[0]}" == "num" ]]; then
                num
                continue
            fi
            
            # Check for numeric input (file number)
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                # Check if file list exists
                if [[ ${#num_files[@]} -eq 0 ]]; then
                    echo "❌ Error: Please run 'num' command first to view file list"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#num_files[@]} ]]; then
                    echo "❌ Error: Invalid file number (enter 1-${#num_files[@]})"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selected_file="${num_files[$((selection-1))]}"
                local compiler="${input[1]}"  # Optional compiler argument
                echo "📁 Running file: $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                echo "└───────────────────────────────────"
                echo ""
                continue
            fi
            
            # Parse user input
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            # Pre-validation: must be supported file extension, error immediately if not, skip find
            case "$filename" in
                *.c|*.cpp|*.cxx|*.cc|*.java|*.py|*.sh|*.js|*.php|*.m|*.f|*.f90|*.f95|*.f03|*.f08|*.rs|*.kt|*.go)
                    : # Valid extension, continue
                    ;;
                *)
                    echo "❌ Unknown command or unsupported file type: '$filename'"
                    echo "   💡 Input '--help' for help, 'num' to list source files"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                    ;;
            esac
            
            # Recursively find file
            local _search_dir="${VTARGET:-$source_dir}"
            local found_files=($(find_file_recursive "$filename" "$_search_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                # Show full path in error message
                local source_full_path=$(realpath "$_search_dir" 2>/dev/null || echo "$_search_dir")
                echo "❌ Error: File '$filename' not found in '${source_full_path}' and its subdirectories"
                echo "└───────────────────────────────────"
                echo ""
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 Multiple files named '$filename' found:"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 Please select file number [number (compiler)]: " -a sel_input
                local selection="${sel_input[0]}"
                local override_compiler="${sel_input[1]}"
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Error: Invalid number"
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
# Main Function
# ==============================================
main() {
    # Parse command line seed arguments first
    load_seed_from_args "$@"

    # When no command line args, overlay built-in seed
    if [[ $# -eq 0 ]]; then
        load_stored_seed
    fi

    initialize

    echo ""
    show_banner
    echo "👋 Welcome to colM1_Eng!"
    echo "   • Input '--help' for help"
    echo "   • Input 'num' to view source file list"
    echo "   • Input 'status' to view compiler status"
    echo "📂 Source: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "🛠️ Output: $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    # Check if current path matches built-in seed
    local _script_path
    _script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local _stored_raw
    _stored_raw=$(grep '^# \[COL_SEED\]' "$_script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')
    if [[ -n "$_stored_raw" ]]; then
        # Parse f- and t- from seed
        local _seed_src="" _seed_out=""
        for _tok in $_stored_raw; do
            [[ "$_tok" == f-* ]] && _seed_src="${_tok#f-}"
            [[ "$_tok" == t-* ]] && _seed_out="${_tok#t-}"
        done
        local _cur_src _cur_out _s_src _s_out
        _cur_src=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
        _cur_out=$(realpath "$output_dir" 2>/dev/null || echo "$output_dir")
        _s_src=$(realpath "$_seed_src" 2>/dev/null || echo "$_seed_src")
        _s_out=$(realpath "$_seed_out" 2>/dev/null || echo "$_seed_out")
        if [[ "$_cur_src" != "$_s_src" || "$_cur_out" != "$_s_out" ]]; then
            echo "⚡ Temporary execution  Seed record: $_stored_raw"
        fi
    fi
    echo "└───────────────────────────────────"
    echo ""

    # When no command line args, enter seed input REPL
    if [[ $# -eq 0 ]]; then
        seed_startup_repl
    fi

    # Enter main interface
    main_interface
}

# Start program
main "$@"
