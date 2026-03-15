#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# ngoq SeHlaw De'
# ==============================================
VERSION="M1.0.Klg"

# ==============================================
# batlh jan (version box)
# ==============================================
show_banner() {
    echo "┌──────────────────────────────────┐"
    echo "│         col $VERSION             │"
    echo "│    tlhIngan Hol ngoq rurmoH      │"
    echo "└──────────────────────────────────┘"
}

# ==============================================
# QaH De' cha'
# ==============================================
show_help() {
    show_banner
    echo ""
    echo "📋 Hol Sepmey — ghItlhwI' lo'laH:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin, Go"
    echo ""
    echo "🔍 ghaj:"
    echo "   • Termux Sep Dub"
    echo "   • ngoq ghItlh nejHom"
    echo "   • Ctrl+C — ngoq De' jan cha'"
    echo ""
    echo "🚀 DaH yItagh:"
    echo "   ./colM1_Kli.sh [ngoq De' jan]"
    echo ""
    echo "⚙️  ngoq De' jan mech:"
    echo "   f-<veng>     ngoq ghItlh veng"
    echo "   t-<veng>     chenmoH ngoq veng"
    echo "   op-<mech>    ghItlhwI'-Hol mech"
    echo ""
    echo "🗡️  lo' mech:"
    echo "   <pong>              ngoq yIchu'"
    echo "   <pong> <ghItlhwI'>  ghItlhwI' wej lo'"
    echo "   num                 ngoq ghItlh mI' cha'"
    echo "   <mI'>               mI' ngoq yIchu'"
    echo "   vcd <veng>         VTARGET yIcher (~/Hop Dulegh)"
    echo "   vcd -               VTARGET yIteq"
    echo "   vcd                VTARGET yIlegh"
    echo "   vls [mech]         VTARGET Daqvo' ls yIchu'"
    echo "   checkavails         ghItlhwI' tu'lu'meH yIpay"
    echo "   -h, --help          QaH De' yIlegh"
    echo "   -v, --version       batlh jan yIlegh"
    echo ""
    echo "📝 mu'tlheghDaq:"
    echo "   ./colM1_Kli.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   num"
    echo "   1"
    echo "   checkavails"
    echo "   Ctrl+C (ngoq De' jan yIlegh)"
    echo ""
    echo "💡 po'wI' De': bISuvtaHvIS --help qoj --version yIjatlh"
    echo ""
    echo "🌐 DaH Sep QaQ Hol:"
    echo ""
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  tu'be'lu'   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# batlh jan De' cha'
# ==============================================
show_version() {
    show_banner
    echo ""
}

# ==============================================
# Ctrl+C — ngoq De' jan
# ==============================================
trap 'show_exit_seed; echo -e "\nHeghlu'\''meH QaQ jajvam"; exit 0' SIGINT

# ==============================================
# jan: veng pong nap cha'
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
# ngoq De' jan cha'
# ==============================================
show_exit_seed() {
    echo "┌──────────────────────────────────┐"
    echo "│         ngoq De' jan             │"
    echo "│  DaH yItagh — mu'tlhegh:         │"

    local current_ops=()

    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done

    local seed_command="./colM1_Kli.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"

    echo "  $seed_command"
    echo "└───────────────────────────────────"
}

# ==============================================
# ngoq De' jan lo'
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
            echo "⚠️  yIDoH — De' tu'be'lu': $arg (vIlajbe')"
        fi
    done
}

# ==============================================
# Hol-ghItlhwI' mech janmey (core config)
# Structure: Hol -> "ghItlhwI'_wa':mI',mI',..."
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

# Sep mIwmey
declare -A lang_default_compiler  # lo'wI' ghItlhwI' Hol
source_dir=""                     # ngoq ghItlh veng
output_dir=""                     # chenmoH ngoq veng
execute=true                      # chenmoHDI' yIchu'
delete_after=true                 # chu'DI' yIteq
VTARGET=""                        # v-ghom VTARGET veng

# ==============================================
# jan: Hol De' mujmey
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# jan: ngoq tu'lu''a'
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# jan: ghItlhwI' pong SeH
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
            version="sh (Sep nap)" ;;
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
# jan: ghItlhwI' chermeH De'
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
        *) echo "(yIcher $compiler)" ;;
    esac
}

# ==============================================
# jan: ngoq ghItlh nejtaH
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"

    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth 5 -name "$filename" -type f -print0 2>/dev/null)

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
# ghItlhwI'-Hol mech lo' (auto-init)
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
                echo "⚠️  yIDoH — Hol tu'be'lu': '$lang' (vIlajbe')"
                continue
            fi

            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  yIDoH — ghItlhwI' '$compiler' Hol '$lang' Dalo'laHbe' (vIlajbe')"
                continue
            fi

            lang_default_compiler[$lang]=$compiler

            if ! is_installed "$compiler"; then
                echo "⚠️  yIDoH: $compiler tu'be'lu'"
                echo "   💡 yIcher: $(get_install_hint "$compiler")"
            fi
        else
            echo "⚠️  yIDoH — De' tu'be'lu': '$op' (vIlajbe')"
        fi
    done
}

# ==============================================
# tagh mIw
# ==============================================
initialize() {
    local script_dir=$(dirname "$0")

    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}

    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi

    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  yIDoH — ngoq veng tu'be'lu', nap lo'"
        source_dir=$default_source
    fi

    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}

    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi

    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  yIDoH — chenmoH veng tu'be'lu', nap lo'"
        output_dir=$default_output
    fi

    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done

    if [[ -n "$op_codes" ]]; then
        apply_compiler_language_pairs "$op_codes"
    fi
}

# ==============================================
# ngoq ghItlh mI' cha'
# (Hol DFS pre-order: './' wa'DIch, vaj Hol-pIq)
# ==============================================
num() {
    echo "┌──────────────────────────────────┐"
    echo "│      ngoq ghItlh mI' janmey      │"
    echo "└──────────────────────────────────┘"

    local abs_source
    local _num_base="${VTARGET:-$source_dir}"
    abs_source=$(realpath "$_num_base" 2>/dev/null || echo "$_num_base")

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
        echo "❌ ngoq ghItlh tu'be'lu' — veng Daq nejHom"
        echo "└───────────────────────────────────"
        echo ""
        return 0
    fi

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

    echo "ngoq ghItlh tu'lu': ${#all_files[@]}"

    local counter=1
    num_files=()

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
            num_files+=("$file")
            ((counter++))
        done < <(echo "${_dir_files[$dir]}" | sort)
    done

    echo ""
    echo "💡 mI' yIjatlh — ngoq ghItlh yIchu'"
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# v-ghom: VTARGET SeHlaw
# ==============================================

# vcd: VTARGET yIcher / yIlegh / yIteq
vcd() {
    local target="${1:-}"

    if [[ -z "$target" ]]; then
        echo "┌──────────────────────────────────┐"
        if [[ -z "$VTARGET" ]]; then
            echo "│  📍 VTARGET tu'be'"
            echo "│     DaH lo': $(format_path_for_display "$source_dir")"
        else
            echo "│  ⚔️  VTARGET: $VTARGET"
        fi
        echo "└───────────────────────────────────"
        echo ""
        return 0
    fi

    if [[ "$target" == "-" ]]; then
        VTARGET=""
        echo "└─ VTARGET yIteq — nap lo': $(format_path_for_display "$source_dir")"
        echo ""
        return 0
    fi

    if [[ "$target" != /* ]]; then
        local _base="${VTARGET:-$source_dir}"
        target="$_base/$target"
    fi

    if [[ ! -d "$target" ]]; then
        echo "❌ Qagh — veng tu'be'lu': '$target'"
        echo "└───────────────────────────────────"
        echo ""
        return 1
    fi

    VTARGET=$(realpath "$target" 2>/dev/null || echo "$target")
    echo "└─ ⚔️  VTARGET yIcher: $VTARGET"
    echo ""
    return 0
}

# vls: VTARGET Daqvo' ls (mech lo'laH)
vls() {
    local target="${VTARGET:-$source_dir}"
    ls "$@" "$target"
}

# ==============================================
# jan: ngoq mIw cha' (inline refresh)
# lo': run_compiler <ghItlhwI' mech...>
# ==============================================
run_compiler() {
    local tmp_err="/tmp/_col_err_$$"
    printf "⚔️  ngoq vISuv..."
    "$@" 2>"$tmp_err"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        printf "\r✅ Qapla'!\n"
    else
        printf "\r❌ bIluj!\n"
        cat "$tmp_err"
    fi
    rm -f "$tmp_err"
    return $rc
}

# ==============================================
# ngoq chenmoH 'ej chu' logic
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")

    if [[ ! -f "$full_path" ]]; then
        echo "❌ Qagh — ngoq ghItlh tu'be': '$full_path'"
        return 1
    fi

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
            echo "❌ Qagh — Hol tu'be': '$filename'"
            return 1
            ;;
    esac

    if [[ -n "$custom_compiler" ]]; then
        compiler="$custom_compiler"
        echo "⚠️  ghItlhwI' wej lo': $compiler"
    else
        compiler=${lang_default_compiler[$lang]}
    fi

    if ! is_installed "$compiler"; then
        echo "❌ Qagh — ghItlhwI' tu'be': '$compiler'"
        echo "   💡 yIcher: $(get_install_hint "$compiler")"
        return 1
    fi

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
            echo "❌ Qagh — ghItlhwI' lo'laHbe': '$compiler'"
            cd "$original_dir"
            return 1
            ;;
    esac

    cd "$original_dir"
    return 0
}

# ==============================================
# ghItlhwI' tu'lu'meH SeH
# ==============================================
check_availability() {
    echo "┌──────────────────────────────────┐"
    echo "│     ghItlhwI' tu'lu'meH SeH      │"
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
                echo "  ${ptr} ❌ ${name_col}  tu'be'lu'  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└───────────────────────────────────"
    echo ""
}

# ==============================================
# wa'DIch ghom SeHlaw
# ==============================================
main_interface() {
    num_files=()

    while true; do
        if [[ -n "$VTARGET" ]]; then
            local _prompt_dir=$(format_path_for_display "$VTARGET")
            read -p "🔴[colM1_Kli]⚔️  $_prompt_dir ❯ " -a input
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
            elif [[ "${input[0]}" == "checkavails" ]]; then
                check_availability
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
                    echo "❌ Qagh — wa'DIch 'num' yIchu'"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi

                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#num_files[@]} ]]; then
                    echo "❌ Qagh — mI' Qagh (1 — ${#num_files[@]})"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                fi

                local selected_file="${num_files[$((selection-1))]}"
                local compiler="${input[1]}"
                echo "📁 ngoq ghItlh yIchu': $(basename "$selected_file")"
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
                    echo "❌ jIyajbe' — Hol tu'be': '$filename'"
                    echo "   💡 '--help' yIjatlh, qoj 'num'"
                    echo "└───────────────────────────────────"
                    echo ""
                    continue
                    ;;
            esac

            local _search_dir="${VTARGET:-$source_dir}"
            local found_files=($(find_file_recursive "$filename" "$_search_dir"))

            if [[ ${#found_files[@]} -eq 0 ]]; then
                local source_full_path=$(realpath "$_search_dir" 2>/dev/null || echo "$_search_dir")
                echo "❌ Qagh — '$filename' tu'be': '${source_full_path}'"
                echo "└───────────────────────────────────"
                echo ""
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 '$filename' — ghItlh law' tu'lu':"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 mI' yIwIv [mI' (ghItlhwI')]: " -a sel_input
                local selection="${sel_input[0]}"
                local override_compiler="${sel_input[1]}"
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Qagh — mI' Qagh"
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
# wa'DIch mIw
# ==============================================
main() {
    load_seed_from_args "$@"
    initialize

    echo ""
    show_banner
    echo "👋 nuqneH — colM1_Kli DaH yItagh!"
    echo "   • '--help' — QaH De'"
    echo "   • 'num' — ngoq ghItlh mI' cha'"
    echo "   • 'checkavails' — ghItlhwI' SeH"
    echo "📁 ngoq veng: $(realpath "$source_dir" 2>/dev/null || echo "$source_dir")"
    echo "└───────────────────────────────────"
    echo ""

    main_interface
}

# tlhIngan maH!
main "$@"
