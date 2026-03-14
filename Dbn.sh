#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
#
# I'm Lieutenant Frank Drebin, Police Squad.
# ==============================================
VERSION="Actually Jane and I were going to keep it"

# ==============================================
# And don't ever let me catch you guys in America!
# ==============================================
show_help() {
    echo "┌────────────────────────────────────────┐"
    echo "│           colL $VERSION              │"
    echo "│  I'm Lieutenant Frank Drebin, Police   │"
    echo "│  Squad. Don't let me catch you guys!   │"
    echo "└────────────────────────────────────────┘"
    echo " Guess why you see it here, like, the former repo was, like, not a formal"
    echo " But it sure aint no failure, and its fun to see re-constructions"
    echo " The time when you see the Frank Drebin version of this brand new branch, is when everything is settled"
    echo " Like, good luck with that--------2026.3.14 col series restart, based on former colL5.sh. The name colL is now re-occupied, in allignment with the new col series"
    echo ""
    echo "📋 Welcome home, Frank. Good work in Beirut:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin"
    echo ""
    echo "🔍 I want to know one thing — is it true about Victoria?"
    echo "   • I'm afraid so. She ran off with some guy."
    echo "   • They got married last week."
    echo "   • Then it's over. All of this is meaningless."
    echo ""
    echo "🚀 I did it for her. Everything. And now she's gone:"
    echo "   ./colL5_Dbn.sh [config-seed]"
    echo ""
    echo "⚙️  Sure, you think I'm a big hero:"
    echo "   f-<path>     Do any of you understand"
    echo "   t-<path>     how a man can hurt inside?"
    echo "   op-<map>     Frank, they're not here for you."
    echo ""
    echo "🎮 'Weird Al' Yankovic is on the plane:"
    echo "   <file>           I can't get her out of my mind"
    echo "   <file> <compiler>  I trusted her and followed my heart"
    echo "   vls                Foolishly, it seems"
    echo "   <number>           I'm just gonna have to learn to forget"
    echo "   checkavails        That's why I took my vacation in Beirut"
    echo "   -h, --help         To find some peace"
    echo "   -v, --version      It won't be easy"
    echo ""
    echo "📝 Everywhere I look, something reminds me of her:"
    echo "   ./colL5_Dbn.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   vls"
    echo "   1"
    echo "   checkavails"
    echo "   Ctrl+C (Maybe cops and women just don't mix)"
    echo ""
    echo "💡 Mrs. Nordberg, I think we can save your husband's arm."
    echo "   Where would you like it sent?"
    echo ""
    echo "🌐 Frank! I'm so glad you came!"
    echo ""
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  Nordberg!   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo ""
}

# ==============================================
# Wilma, I came as soon as I heard.
# ==============================================
show_version() {
    echo "┌─────────────────────────────┐"
    echo "│   Nordberg, it's Frank,     │"
    echo "│       your buddy.           │"
    echo "│           v$VERSION           │"
    echo "└─────────────────────────────┘"
}

# ==============================================
# I... love you.
# ==============================================
trap 'show_exit_seed; echo -e "\nI love you, too, Nordberg. Who were they?"; exit 0' SIGINT

# ==============================================
# Ship... Boat...
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
# That's right. A boat. When you're better,
# we'll go sailing together, just like last year.
# ==============================================
show_exit_seed() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        No... Drugs.         │"
    echo "│ Nurse, give this man some   │"
    echo "│ drugs! Can't you see he's   │"
    echo "│ in pain? Give him a shot!   │"
    
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    local seed_command="./colL5_Dbn.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└─────────────────────────────┘"
}

# ==============================================
# Nordberg, that's a pretty tall order.
# Give me a couple of days on that one.
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
            echo "📁 He was such a good man, Frank: $source_dir (recursive)"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
            echo "📂 He never wanted to hurt anyone: $output_dir"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
            echo "⚙️  Who would do such a thing? $op_codes"
        else
            echo "⚠️  It's hard to tell. A gang of thugs: $arg (ignored)"
        fi
    done
}

# ==============================================
# A blackmailer, an angry husband, a gay lover...
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

declare -A lang_default_compiler
source_dir=""
output_dir=""
execute=true
delete_after=true
declare -A extension_commands
declare -A extension_files

# ==============================================
# Frank, get a hold of yourself!
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# A good cop — needlessly cut down by some
# cowardly hoodlums. No way for a man to die.
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# You're right, Ed. A parachute not opening —
# that's the way to die.
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
            version="sh (Getting caught in a combine)" ;;
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
        *)
            version=$("$compiler" --version 2>/dev/null | head -1) ;;
    esac
    echo "$version"
}

# ==============================================
# Having your nuts bit off by a Laplander.
# That's the way I want to go.
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
        *) echo "(Don't worry, Wilma. Your husband is gonna be all right.)" ;;
    esac
}

# ==============================================
# Just think positive. Never let a doubt
# enter your mind.
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
# But don't wait till the last minute to fill
# out those organ donor cards.
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })
    
    for op in "${op_list[@]}"; do
        if [[ $op == f-* ]]; then
            source_dir="${op#f-}"
            echo "📁 Unless he's a drooling vegetable: $source_dir"
        elif [[ $op == t-* ]]; then
            output_dir="${op#t-}"
            echo "📂 But that's only common sense: $output_dir"
        elif [[ $op == *-* ]]; then
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Ed and I drove to where Nordberg had been found floating: '$lang' (ignored)"
                continue
            fi
            
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  Without leads, you have to start somewhere: '$compiler' for $lang (ignored)"
                continue
            fi
            
            lang_default_compiler[$lang]=$compiler
            echo "✅ And that was the harbour: ${lang} → $compiler"
            
            if ! is_installed "$compiler"; then
                echo "⚠️  Do you wanna take a dinghy? $compiler not installed"
                case "$compiler" in
                    python3|pypy|pypy3) echo "   💡 No, I took care of that at the press conference: pkg install python" ;;
                    gcc|g++|clang|clang++) echo "   💡 It doesn't make sense: pkg install clang" ;;
                    javac) echo "   💡 Good policeman, bright future: pkg install openjdk-17" ;;
                    node) echo "   💡 Then something like this happens: pkg install nodejs" ;;
                    php) echo "   💡 My memory ain't so great: pkg install php" ;;
                    bash|sh) echo "   💡 Maybe this'll refresh your memory: pkg install bash" ;;
                    gfortran) echo "   💡 Still hazy: pkg install gcc-gfortran" ;;
                    rustc) echo "   💡 How about this? pkg install rust" ;;
                    kotlinc) echo "   💡 I remember. Why do you want to know? pkg install kotlin" ;;
                    octave) echo "   💡 I can't tell you: pkg install octave" ;;
                esac
            fi
        else
            echo "⚠️  Maybe this'll help: '$op' (ignored)"
        fi
    done
}

# ==============================================
# I don't think I should. Still don't think so?
# ==============================================
initialize() {
    local script_dir=$(dirname "$0")
    
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  It's Nordberg, he's a cop. No, he was dealin' H. He was dirty!"
        source_dir=$default_source
    fi
    
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  Scum! I ought to run you in right now!"
        output_dir=$default_output
    fi
    
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    if [[ -n "$op_codes" ]]; then
        echo -e "\n🔧 Vincent Ludwig owned one of the city's largest corporations..."
        apply_compiler_language_pairs "$op_codes"
    fi
    
    echo -e "\n✅ A respected businessman and civic leader!"
    
    local script_full_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
    echo "📄 He was to chair the Queen's reception committee: $script_full_path"
    echo "📁 Now I was about to question him about drugs and attempted murder: $source_full_path"
}

# ==============================================
# Lieutenant. — The feeling is mutual.
# ==============================================
vls() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│  Cuban? No, Dutch-Irish.    │"
    echo "│  My father was from Wales.  │"
    echo "└─────────────────────────────┘"
    
    local found_files=()
    
    local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
    
    for ext in "${extensions[@]}"; do
        while IFS= read -r -d '' file; do
            found_files+=("$file")
        done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
    done
    
    if [[ ${#found_files[@]} -eq 0 ]]; then
        echo "❌ What a magnificent office."
        echo "└─────────────────────────────┘"
        return 0
    fi
    
    echo "Most objects I have collected: ${#found_files[@]} files"
    echo ""
    for i in "${!found_files[@]}"; do
        local filename=$(basename "${found_files[$i]}")
        local filepath="${found_files[$i]}"
        printf "  %2d. %s\n" $((i+1)) "$filename"
    done
    echo ""
    echo "💡 This particular fish is valued at over twenty thousand dollars"
    echo "└─────────────────────────────┘"
    
    vls_files=("${found_files[@]}")
}

# ==============================================
# That's fascinating.
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    if [[ ! -f "$full_path" ]]; then
        echo "❌ But I'm sure you didn't pay this visit for a lecture on fine art: '$full_path'"
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
        *) 
            echo "❌ To what do I owe the honour? '$filename'"
            return 1
            ;;
    esac
    
    if [[ -n "$custom_compiler" ]]; then
        compiler="$custom_compiler"
        echo "⚠️  I'm investigating the attempted murder of a dock worker: $compiler"
    else
        compiler=${lang_default_compiler[$lang]}
    fi
    
    if ! is_installed "$compiler"; then
        echo "❌ A man named Nordberg — a police officer: '$compiler' not installed"
        case "$compiler" in
            python3|pypy|pypy3) echo "   💡 He was shot six times: pkg install python" ;;
            gcc|g++|clang|clang++) echo "   💡 Fortunately, the bullets missed every vital organ: pkg install clang" ;;
            javac) echo "   💡 He's in the intensive care ward: pkg install openjdk-17" ;;
            node) echo "   💡 At Our Lady of the Worthless Miracle: pkg install nodejs" ;;
            php) echo "   💡 Her hair was the colour of gold in old paintings: pkg install php" ;;
            bash|sh) echo "   💡 She had a full set of curves: pkg install bash" ;;
            gfortran) echo "   💡 And the kind of legs you'd like to...: pkg install gcc-gfortran" ;;
            rustc) echo "   💡 This week he is being honored: pkg install rust" ;;
            kotlinc) echo "   💡 For his 1,000th drug dealer killed: pkg install kotlin" ;;
            octave) echo "   💡 Please welcome Lieutenant Frank Drebin: pkg install octave" ;;
        esac
        return 1
    fi
    
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│  In all honesty, the last   │"
    echo "│  two I backed over with my  │"
    echo "│  car. Luckily, they were    │"
    echo "│  drug dealers: $filename"
    echo "│ Lang: $lang | Compiler: $compiler │"
    echo "└─────────────────────────────┘"
    
    local original_dir=$(pwd)
    
    case "$compiler" in
        python3|pypy|pypy3)
            echo "🚀 My name is Sergeant Frank Drebin, Detective Lieutenant, Police Squad..."
            "$compiler" "$full_path"
            ;;
        
        gcc|clang)
            local output_file="${output_dir}/$(basename "$filename" .c)"
            echo "🔨 I was getting my car washed when I heard the call..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ There had been a bombing: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 And I was on my way to advise the DC Police..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  As part of the President's 'Operation Scum Roundup': $output_file"
                    fi
                fi
            else
                echo "❌ Congratulations, I understand that Edna's pregnant again."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        g++|clang++)
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            echo "🔨 Yes, and if I catch the guy who did it..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ They've searched the building: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 No sign of a break-in, no money missing..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  This was one hell of an explosion: $output_file"
                    fi
                fi
            else
                echo "❌ Any other victims? You're standing on one right now."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        javac)
            local classname=$(basename "$filename" .java)
            echo "🔨 Oh, I see..."
            javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ There's one witness — a woman: ${output_dir}/${classname}.class"
                if [[ $execute == true ]]; then
                    echo "🏃 She saw a man leaving just before the explosion..."
                    (cd "$output_dir" && java "$classname")
                    if [[ $delete_after == true ]]; then
                        rm -f "${output_dir}/${classname}.class"
                        echo "🗑️  I'd better do it while it's still fresh: ${classname}.class"
                    fi
                fi
            else
                echo "❌ Not now. She fainted dead away."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        bash|sh)
            echo "🚀 She took a knock on the head. She looks pretty bad..."
            "$compiler" "$full_path"
            ;;
        
        node)
            echo "🚀 I'll handle it. Not that bad..."
            "$compiler" "$full_path"
            ;;
        
        php)
            echo "🚀 I couldn't believe it was her. It was like a dream..."
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
            echo "🔨 But there she was, just like I remembered her..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ That delicately beautiful face: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 And a body that could melt a cheese sandwich from across the room..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  And breasts that seem to say, 'Hey, look at these!': $output_file"
                    fi
                fi
            else
                echo "❌ She made you drop to your knees and thank God that you were a man."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        rustc)
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            echo "🔨 Jane. I didn't know you lived here..."
            "$compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ I moved here two years ago: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 How are the children?..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  We didn't have any children: $output_file"
                    fi
                fi
            else
                echo "❌ Yes, of course."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        kotlinc)
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            echo "🔨 Are you all right? I'm soaking wet..."
            "$compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ I'll get the talcum powder: $jar_file"
                if [[ $execute == true ]]; then
                    echo "🏃 It's not that. I had a nightmare..."
                    java -jar "$jar_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$jar_file"
                        echo "🗑️  Crime all around me, I couldn't stop it: $jar_file"
                    fi
                fi
            else
                echo "❌ Frank, it was just a dream."
                cd "$original_dir"
                return 1
            fi
            ;;
        
        octave)
            echo "🚀 You're right. All I need is a good night's rest..."
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        *)
            echo "❌ Tomorrow everything will be fine: '$compiler'"
            cd "$original_dir"
            return 1
            ;;
    esac
    
    cd "$original_dir"
    
    echo "┌─────────────────────────────┐"
    echo "│ A couple needs to get off   │"
    echo "│ on the right foot and not   │"
    echo "│ get caught up in blame.     │"
    echo "└─────────────────────────────┘"
    return 0
}

# ==============================================
# Now, which one of you is impotent?
# That would be him.
# ==============================================
check_availability() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│ Yes, of course. Why don't   │"
    echo "│ you ask who's frigid?       │"
    echo "│ That would be him.          │"
    echo "└─────────────────────────────┘"
    
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
                echo "  ${ptr} ❌ ${name_col}  How would you know?  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└─────────────────────────────┘"
}

# ==============================================
# He resents that I'm a working woman.
# He has no idea what a woman wants or needs.
# ==============================================
main_interface() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│  You're so insensitive.     │"
    echo "│  Is this that toilet seat   │"
    echo "│  thing?                     │"
    echo "└─────────────────────────────┘"
    echo "📝 I want to have a baby:"
    echo "   • Every time we make love, you have a headache"
    echo "   • I'm not a piece of meat. I'm trying!"
    echo "   • I've got ointments, lotions, creams, books, things that vibrate..."
    echo "   • Ctrl+C = Maybe it's your fault"
    echo "└─────────────────────────────┘"
    
    local vls_files=()
    
    while true; do
        local source_dir_display=$(format_path_for_display "$source_dir")
        read -p "🟢[Drebin] $source_dir_display ❯ " -a input
        
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
                vls_files=()
                local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
                for ext in "${extensions[@]}"; do
                    while IFS= read -r -d '' file; do
                        vls_files+=("$file")
                    done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
                done
                continue
            fi
            
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                if [[ ${#vls_files[@]} -eq 0 ]]; then
                    echo "❌ Have you tried sexy lingerie? Lacy underwear? A black teddy?"
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#vls_files[@]} ]]; then
                    echo "❌ I've tried them all. They don't work. (1-${#vls_files[@]})"
                    continue
                fi
                
                local selected_file="${vls_files[$((selection-1))]}"
                local compiler="${input[1]}"
                echo "📁 Oh, honey, it's just that I love you so much: $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                continue
            fi
            
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            case "$filename" in
                *.c|*.cpp|*.cxx|*.cc|*.java|*.py|*.sh|*.js|*.php|*.m|*.f|*.f90|*.f95|*.f03|*.f08|*.rs|*.kt)
                    :
                    ;;
                *)
                    echo "❌ My little lover sparrow. My puppy wuppy wuvver: '$filename'"
                    echo "   💡 '--help' = My little love biscuit, 'vls' = My little snookie wookums"
                    continue
                    ;;
            esac
            
            local found_files=($(find_file_recursive "$filename" "$source_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
                echo "❌ My little lady cheesy puffy. Mr. and Mrs. Drebin, please — I'm a diabetic: '$filename' in '${source_full_path}'"
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 Ed, Nordberg! It's been a long time! '$filename':"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 Good to see you, buddy. You look terrific: " selection
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ I'm taking a step class, and I got a thigh master for Christmas."
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
# Where are my manners? Come on in!
# ==============================================
main() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        colL v$VERSION         │"
    echo "│  We're having trouble with  │"
    echo "│  a terrorist threat.        │"
    echo "│  Police Squad is certain... │"
    echo "└─────────────────────────────┘"
    echo "👋 I'd love a cupcake!"
    echo "   • '--help' = That coffee smells great"
    echo "   • 'vls' = I grind my own beans"
    echo "   • 'checkavails' = They're great! Made from scratch"
    echo "└─────────────────────────────┘"
    
    load_seed_from_args "$@"
    
    initialize
    
    main_interface
}

# We may have a lead on a suspect in the City Hall bombing attempt.
main "$@"
