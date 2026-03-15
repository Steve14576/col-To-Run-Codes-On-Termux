#!/data/data/com.termux/files/usr/bin/bash
# [COL_SEED]

# ==============================================
# ghun bo'Degh (Script Version)
# ==============================================
VERSION="M1.1.Klg"

# ==============================================
# peQ mIw (Unified Banner)
# ==============================================
show_banner() {
    echo "┌──────────────────────────────────┐"
    echo "│          col $VERSION            │"
    echo "│   Holmey lI'meH De'wI' much     │"
    echo "└──────────────────────────────────┘"
}

# ==============================================
# QaH (Show Help)
# ==============================================
show_help() {
    show_banner
    echo ""
    echo "📋 Holmey lI':"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin, Go"
    echo ""
    echo "🔍 De':"
    echo "   • Termux qach lI'"
    echo "   • De'wI'Hom lI'"
    echo "   • Ctrl+C cheghDI' De'wI'Hom cha'"
    echo ""
    echo "🚀 matlh:"
    echo "   ./colM1_Kli.sh [De'wI'Hom]"
    echo ""
    echo "⚙️  De'wI'Hom DuH:"
    echo "   f-<De'wI'Hom>     De'wI'Hom SeH"
    echo "   t-<chenmoH De'wI'Hom>   chenmoH De'wI'Hom SeH"
    echo "   op-<much>          much De'wI'Hom-Hol"
    echo ""
    echo "🎮 lI':"
    echo "   <De'wI'Hom>           De'wI'Hom lI'"
    echo "   <De'wI'Hom> <much>    much lI'"
    echo "   num                   De'wI'HomHom lI'"
    echo "   <mI'>                 mI' De'wI'Hom lI'"
    echo "   vcd <HeH>            HeH SeH (~/'e' Hur)"
    echo "   vcd -                 HeH teq"
    echo "   vcd                   HeH legh"
    echo "   vls [DuH]            HeH ls lI'"
    echo "   status                DaH HeH+much Qap (checkavails)"
    echo "   save                  De'wI'Hom much De'wI'Hom much"
    echo "   reset                 De'wI'Hom teq, pIm"
    echo "   -h, --help            QaH legh"
    echo "   -v, --version         bo'Degh legh"
    echo ""
    echo "📝 mIw:"
    echo "   ./colM1_Kli.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   num"
    echo "   1"
    echo "   status"
    echo "   save"
    echo "   reset"
    echo "   Ctrl+C (chegh De'wI'Hom cha')"
    echo ""
    echo "💡 qeq: lI' mIw --help pagh --version lI'laH"
    echo ""
    echo "🌐 DaH Hol lI' Qap:"
    echo ""
    # Hol legh lI' (sort)
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        # DaH much lI', pagh pIm much
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  lI'be'   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# bo'Degh legh (Show Version)
# ==============================================
show_version() {
    show_banner
    echo ""
}

# ==============================================
# Ctrl+C ghuH, cheghDI' De'wI'Hom cha'
# ==============================================
trap 'show_exit_seed; echo -e "\nghun mev"; exit 0' SIGINT

# ==============================================
# De'wI'Hom: HeH legh much
# ==============================================
format_path_for_display() {
    local path="$1"
    
    # HeH legh
    local full_path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    # HeH tIQ
    if [[ "$full_path" == "/" ]]; then
        echo "/"
        return
    fi
    
    # HeH teq
    full_path=${full_path%/}
    
    # / legh
    local slash_count=$(echo "$full_path" | tr -cd '/' | wc -c)
    
    if [[ $slash_count -le 2 ]]; then
        # HeH mach
        echo "$full_path"
    else
        # HeH tIn, 3 legh
        local basename=$(basename "$full_path")
        local parent_dir=$(basename "$(dirname "$full_path")")
        local grandparent_dir=$(basename "$(dirname "$(dirname "$full_path")")")
        echo ".../$grandparent_dir/$parent_dir/$basename"
    fi
}

# ==============================================
# chegh De'wI'Hom cha' (Show Exit Seed)
# ==============================================
show_exit_seed() {
    echo "┌──────────────────────────────────┐"
    echo "│         De'wI'Hom               │"
    echo "│  DaH lI' much lI':              │"
    
    # DaH De'wI'Hom much
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    # De'wI'Hom much
    local seed_command="./colM1_Kli.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└───────────────────────────────────"
}

# ==============================================
# lI' De'wI'Hom much (Load Seed from Args)
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    
    # HeH pIm lI'
    source_dir=$default_source
    output_dir=$default_output
    op_codes=""
    
    # DuH legh
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
            echo "⚠️  DuH lI'be': $arg (teq)"
        fi
    done
}

# ==============================================
# De'wI'Hom much: lI'/legh/cha'/teq
# ==============================================

# De'wI'Hom lI' (pIm teq)
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

# # [COL_SEED] legh (Load Stored Seed)
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

# De'wI'Hom much cha' (Save Seed)
save_seed() {
    local script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local seed_str="f-${source_dir} t-${output_dir}"
    # pIm much teq
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
    echo "   └─ 💾 De'wI'Hom cha': $seed_str"
    echo ""
}

# De'wI'Hom much teq (Reset Seed)
reset_seed() {
    local script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    sed -i "s|^# \[COL_SEED\].*|# [COL_SEED]|" "$script_path"
    echo "   └─ 🔄 De'wI'Hom teq"
    echo ""
}

# ==============================================
# De'wI'Hom lI' mini-REPL
# ==============================================
seed_startup_repl() {
    local script_path
    script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local stored
    stored=$(grep '^# \[COL_SEED\]' "$script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')

    echo "┌───────────────────────────────────"
    echo "│  ⚔️ De'wI'Hom SeH  (cha' Enter lI')"
    if [[ -n "$stored" ]]; then
        echo "│  💾 logh lI': $stored"
    else
        echo "│  💾 logh lI': (teq)"
    fi
    echo "│  📝 mIw: f-<HeH>  t-<HeH>  op-<much>-<Hol>  "
    echo "│           [save much]  [reset pIm]"
    echo "└───────────────────────────────────"
    echo ""

    local empty_count=0
    local _rlines=0  # REPL legh (cha' HeH)
    while true; do
        read -rp "  [De'wI'Hom] ⚔️ " seed_input
        (( _rlines++ ))

        if [[ -z "$seed_input" ]]; then
            (( empty_count++ ))
            if [[ $empty_count -ge 2 ]]; then
                break
            fi
            echo "      (cha' Enter lI')"
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

        # save
        if [[ "$seed_input" == "save" ]]; then
            save_seed
            (( _rlines += 2 ))
            continue
        fi

        # save legh
        local do_save=false
        local seed_part="$seed_input"
        if [[ "$seed_input" == *" save" ]]; then
            do_save=true
            seed_part="${seed_input% save}"
        fi

        # De'wI'Hom lI'
        apply_seed_fragment $seed_part

        if $do_save; then
            save_seed
            (( _rlines += 2 ))
        fi
    done
    # _rlines+7 (peQ 6 + HeH 1) teq
    printf '\033[%dA\033[J' "$(( _rlines + 7 ))"
    echo "└─ ⚔️ SeH lI'  f-${source_dir} t-${output_dir}"
    echo ""
    echo "📂 De'wI'Hom: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "🛠️ chenmoH: $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# Hol-much much (Core Config)
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

# HeH De'wI'
declare -A lang_default_compiler  # lo'wI' much
source_dir=""                     # De'wI'Hom HeH
output_dir=""                     # chenmoH HeH
execute=true                      # chenmoH lI'
delete_after=true                 # teq lI'
VTARGET=""                        # v-HeH (~/'e' Hur)

# ==============================================
# De'wI'Hom: Hol much legh
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# De'wI'Hom: much lI' lI'be'
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# De'wI'Hom: much bo'Degh legh
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
            version="sh (ghun pIm)" ;;
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
# De'wI'Hom: much lI' qeq
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
        *) echo "($compiler lI'laHbe')" ;;
    esac
}

# ==============================================
# De'wI'Hom: De'wI'HomHom lI'
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    # De'wI'Hom HeH lI'
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth 5 -name "$filename" -type f -print0 2>/dev/null)
    
    # Android HeH lI'
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
    
    # De'wI'HomHom lI'
    echo "${found_files[@]}"
}

# ==============================================
# much-Hol much (Apply Compiler-Language Pairs)
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
            
            # Hol lI' lI'be'
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Hol '$lang' lI'be' (teq)"
                continue
            fi
            
            # much Hol lI'
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  much '$compiler' Hol '$lang' lI'be' (teq)"
                continue
            fi
            
            # much lI'
            lang_default_compiler[$lang]=$compiler
            
            # much lI' lI'be' qeq
            if ! is_installed "$compiler"; then
                echo "⚠️  qeq: $compiler lI'be'"
                echo "   💡 lI' qeq: $(get_install_hint "$compiler")"
            fi
        else
            echo "⚠️  DuH '$op' lI'be' (teq)"
        fi
    done
}

# ==============================================
# SeH mIw (Initialize)
# ==============================================
initialize() {
    local script_dir=$(dirname "$0")
    
    # 1. De'wI'Hom HeH SeH
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    # HeH pIm
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  De'wI'Hom HeH lI'be', pIm HeH lI'"
        source_dir=$default_source
    fi
    
    # 2. chenmoH HeH SeH
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    # HeH pIm
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  chenmoH HeH lI'be', pIm HeH lI'"
        output_dir=$default_output
    fi
    
    # 3. pIm much SeH
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    # much-Hol much
    if [[ -n "$op_codes" ]]; then
        apply_compiler_language_pairs "$op_codes"
    fi
}

# ==============================================
# De'wI'HomHom lI' (num)
# ==============================================
num() {
    echo "┌──────────────────────────────────┐"
    echo "│      De'wI'HomHom lI'           │"
    echo "└──────────────────────────────────┘"

    local abs_source
    local _num_base="${VTARGET:-$source_dir}"
    abs_source=$(realpath "$_num_base" 2>/dev/null || echo "$_num_base")

    # find DuH
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

    # De'wI'HomHom lI'
    local all_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && all_files+=("$file")
    done < <(find "$abs_source" -maxdepth 5 -mindepth 1 -type f \( "${find_args[@]}" \) 2>/dev/null)

    if [[ ${#all_files[@]} -eq 0 ]]; then
        echo "❌ De'wI'HomHom lI'be'"
        echo "└───────────────────────────────────"
        echo ""
        return 0
    fi

    # HeH legh
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

    # DFS sort
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

    echo "${#all_files[@]} De'wI'HomHom lI':"

    local counter=1
    num_files=()

    for dir in "${sorted_dirs[@]}"; do
        echo ""
        if [[ "$dir" == "." ]]; then
            echo "  ./"
        else
            echo "  $dir/"
        fi

        # De'wI'HomHom legh
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
    echo "💡 mI' De'wI'Hom lI'laH"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# v-HeH SeH (vcd)
# ==============================================
vcd() {
    local target="${1:-}"

    if [[ -z "$target" || "$target" == "-" ]]; then
        # HeH teq
        VTARGET=""
        echo "└─ 🏠 De'wI'Hom: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
        echo ""
        return 0
    fi

    # HeH pIm
    if [[ "$target" != /* ]]; then
        local _base="${VTARGET:-$source_dir}"
        target="$_base/$target"
    fi

    # HeH legh
    if [[ ! -d "$target" ]]; then
        echo "❌ HeH lI'be': '$target'"
        echo "└───────────────────────────────────"
        echo ""
        return 1
    fi

    VTARGET=$(realpath "$target" 2>/dev/null || echo "$target")
    echo "└─ ⚔️ HeH SeH: $VTARGET"
    echo ""
    return 0
}

# vls: HeH ls lI'
vls() {
    local target="${VTARGET:-$source_dir}"
    ls "$@" "$target"
}

# ==============================================
# chenmoH Qap legh (run_compiler)
# ==============================================
run_compiler() {
    local tmp_err="/tmp/_col_err_$$"
    printf "⚔️ chenmoH..."
    "$@" 2>"$tmp_err"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        printf "\r✅ Qapla!\n"
    else
        printf "\r❌ lI'be'\n"
        cat "$tmp_err"
    fi
    rm -f "$tmp_err"
    return $rc
}

# ==============================================
# chenmoH lI' mIw (execute_file)
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    # 1. De'wI'Hom lI' lI'be'
    if [[ ! -f "$full_path" ]]; then
        echo "❌ Qagh: De'wI'Hom '$full_path' lI'be'"
        return 1
    fi
    
    # 2. Hol legh
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
            echo "❌ Qagh: Hol '$filename' lI'be'"
            return 1
            ;;
    esac
    
    # 3. much lI'
    if [[ -n "$custom_compiler" ]]; then
        compiler="$custom_compiler"
        echo "⚠️  much lI': $compiler"
    else
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. much lI' lI'be'
    if ! is_installed "$compiler"; then
        echo "❌ Qagh: much '$compiler' lI'be'"
        echo "   💡 lI' qeq: $(get_install_hint "$compiler")"
        return 1
    fi
    
    # 5. chenmoH lI'
    echo "┌──────────────────────────────────┐"
    echo "│  ▶ $filename  [$lang · $compiler]"
    echo "└──────────────────────────────────┘"
    
    local original_dir=$(pwd)
    
    case "$compiler" in
        python3|pypy|pypy3)
            "$compiler" "$full_path"
            ;;
        
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
        
        bash|sh)
            "$compiler" "$full_path"
            ;;
        
        node)
            "$compiler" "$full_path"
            ;;
        
        php)
            "$compiler" "$full_path"
            ;;
        
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
        
        octave)
            octave --no-gui --eval "run('$full_path')"
            ;;
        
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
        
        *)
            echo "❌ Qagh: much '$compiler' lI'be'"
            cd "$original_dir"
            return 1
            ;;
    esac
    
    cd "$original_dir"
    return 0
}

# ==============================================
# DaH HeH legh (status)
# ==============================================
status() {
    echo "┌──────────────────────────────────┐"
    echo "│           DaH HeH               │"
    echo "└──────────────────────────────────┘"
    echo ""
    echo "  📂 De'wI'Hom: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "  🛠️ chenmoH: $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    [[ -n "$VTARGET" ]] && echo "  ⚔️ HeH:  $VTARGET"
    local script_path
    script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local stored
    stored=$(grep '^# \[COL_SEED\]' "$script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')
    if [[ -n "$stored" ]]; then
        echo "  💾 De'wI'Hom:  $stored"
    else
        echo "  💾 De'wI'Hom:  (teq)"
    fi
    echo ""

    # Hol legh
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
                echo "  ${ptr} ❌ ${name_col}  lI'be'  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# lI' mIw (main_interface)
# ==============================================
main_interface() {
    num_files=()
    
    while true; do
        # VTARGET lI' -> 🔴+⚔️
        if [[ -n "$VTARGET" ]]; then
            local _prompt_dir=$(format_path_for_display "$VTARGET")
            read -p "🔴[colM1_Kli]⚔️ $_prompt_dir ❯ " -a input
        else
            local _prompt_dir=$(format_path_for_display "$source_dir")
            read -p "🔴[colM1_Kli] $_prompt_dir ❯ " -a input
        fi
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
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
            
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                if [[ ${#num_files[@]} -eq 0 ]]; then
                    echo "❌ Qagh: 'num' lI' HeH legh"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#num_files[@]} ]]; then
                    echo "❌ Qagh: mI' lI'be' (1-${#num_files[@]} lI')"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi
                
                local selected_file="${num_files[$((selection-1))]}"
                local compiler="${input[1]}"
                echo "📁 De'wI'Hom lI': $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                echo "└───────────────────────────────────"
                echo ""
                continue
            fi
            
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            case "$filename" in
                *.c|*.cpp|*.cxx|*.cc|*.java|*.py|*.sh|*.js|*.php|*.m|*.f|*.f90|*.f95|*.f03|*.f08|*.rs|*.kt|*.go)
                    :
                    ;;
                *)
                    echo "❌ DuH lI'be' pagh Hol lI'be': '$filename'"
                    echo "   💡 '--help' QaH, 'num' De'wI'HomHom lI'"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                    ;;
            esac
            
            local _search_dir="${VTARGET:-$source_dir}"
            local found_files=($(find_file_recursive "$filename" "$_search_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                local source_full_path=$(realpath "$_search_dir" 2>/dev/null || echo "$_search_dir")
                echo "❌ Qagh: De'wI'Hom '$filename' '${source_full_path}' lI'be'"
                echo "└───────────────────────────────────"
                echo ""
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 De'wI'Hom '$filename' lI':"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 mI' lI': " -a sel_input
                local selection="${sel_input[0]}"
                local override_compiler="${sel_input[1]}"
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Qagh: mI' lI'be'"
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
# ghun mIw (main)
# ==============================================
main() {
    load_seed_from_args "$@"

    if [[ $# -eq 0 ]]; then
        load_stored_seed
    fi

    initialize

    echo ""
    show_banner
    echo "👋 nuqneH — colM1_Kli DaH yItagh!"
    echo "   • '--help' QaH"
    echo "   • 'num' De'wI'HomHom lI'"
    echo "   • 'status' much Qap legh"
    echo "📂 De'wI'Hom: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "🛠️ chenmoH: $(realpath "$output_dir" 2>/dev/null || echo "$output_dir")"
    local _script_path
    _script_path="$(realpath "$0" 2>/dev/null || echo "$0")"
    local _stored_raw
    _stored_raw=$(grep '^# \[COL_SEED\]' "$_script_path" 2>/dev/null | sed 's/^# \[COL_SEED\] \?//')
    if [[ -n "$_stored_raw" ]]; then
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
            echo "⚡ lI'  De'wI'Hom: $_stored_raw"
        fi
    fi
    echo "└───────────────────────────────────"
    echo ""

    if [[ $# -eq 0 ]]; then
        seed_startup_repl
    fi

    main_interface
}

# ghun lI'
main "$@"
