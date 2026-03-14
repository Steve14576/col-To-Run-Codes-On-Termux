#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# 脚本版本信息
# ==============================================
VERSION="Lite.1.0.Chn"

# ==============================================
# 显示帮助信息
# ==============================================
show_help() {
    echo "┌────────────────────────────────────────┐"
    echo "│           colL $VERSION              │"
    echo "│     多语言编译运行工具 (轻量版)        │"
    echo "└────────────────────────────────────────┘"
    echo ""
    echo "📋 支持语言:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin"
    echo ""
    echo "🔍 功能特性:"
    echo "   • 支持Termux环境"
    echo "   • 递归查找源文件"
    echo "   • Ctrl+C退出时显示配置种子"
    echo ""
    echo "🚀 快速开始:"
    echo "   ./colL4_betterui.sh [配置种子]"
    echo ""
    echo "⚙️  配置种子选项:"
    echo "   f-<源文件路径>     配置源文件路径"
    echo "   t-<编译产物路径>   配置编译产物路径"
    echo "   op-<映射>          配置编译器-语言映射"
    echo ""
    echo "🎮 使用方法:"
    echo "   <文件名>           运行指定文件"
    echo "   <文件名> <编译器>  单次指定编译器运行"
    echo "   vls                列出当前目录源文件并编号"
    echo "   <编号>             运行编号对应的文件"
    echo "   checkavails        显示编译器可用性"
    echo "   -h, --help         显示帮助信息"
    echo "   -v, --version      显示版本信息"
    echo ""
    echo "📝 示例:"
    echo "   ./colL4_betterui.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   vls"
    echo "   1"
    echo "   checkavails"
    echo "   Ctrl+C (退出并显示配置种子)"
    echo ""
    echo "💡 提示: 交互模式中也可输入 --help 或 --version"
    echo ""
    echo "🌐 当前环境语言支持状态:"
    echo ""
    # 按语言名排序显示，避免每次顺序不同
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        # 优先使用本次会话已设定的编译器，否则使用内置默认推荐
        local compiler="${lang_default_compiler[$lang]:-$(get_default_default "$lang")}"
        if is_installed "$compiler"; then
            local version=$(get_compiler_version "$compiler")
            printf "   ✅ %-12s → %-8s  %s\n" "$lang" "$compiler" "$version"
        else
            local hint=$(get_install_hint "$compiler")
            printf "   ❌ %-12s → %-8s  未安装   💡 %s\n" "$lang" "$compiler" "$hint"
        fi
    done
    echo ""
}

# ==============================================
# 显示版本信息
# ==============================================
show_version() {
    echo "┌─────────────────────────────┐"
    echo "│      colL 多语言编译工具    │"
    echo "│         (轻量版)            │"
    echo "│           v$VERSION           │"
    echo "└─────────────────────────────┘"
}

# ==============================================
# 捕获Ctrl+C信号，退出时显示当前配置种子
# ==============================================
trap 'show_exit_seed; echo -e "\n程序已终止"; exit 0' SIGINT

# ==============================================
# 工具函数：格式化目录路径显示
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
# 显示退出种子信息
# ==============================================
show_exit_seed() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        配置种子             │"
    echo "│ 下次可使用此命令快速初始化：│"
    
    # 收集当前配置的操作码
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    # 构建种子命令
    local seed_command="./colL4_betterui.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "  $seed_command"
    echo "└─────────────────────────────┘"
}

# ==============================================
# 从命令行参数加载种子
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    
    # 初始化路径为默认值
    source_dir=$default_source
    output_dir=$default_output
    op_codes=""
    
    # 解析参数
    for arg in "${args[@]}"; do
        if [[ $arg == "-h" || $arg == "--help" ]]; then
            show_help
            exit 0
        elif [[ $arg == "-v" || $arg == "--version" ]]; then
            show_version
            exit 0
        elif [[ $arg == f-* ]]; then
            source_dir="${arg#f-}"
            echo "📁 源文件路径: $source_dir (支持递归查找)"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
            echo "📂 编译产物路径: $output_dir"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
            echo "⚙️  编译器映射: $op_codes"
        else
            echo "⚠️  未知参数: $arg (已忽略)"
        fi
    done
}

# ==============================================
# 脚本内部备案：语言-编译器映射表（核心配置）
# 结构：语言名 -> [默认的默认编译器, [备选编译器列表...]]
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

# 状态变量
declare -A lang_default_compiler  # 用户设置的各语言默认编译器
source_dir=""                     # 源文件路径
output_dir=""                     # 编译产物路径
execute=true                      # 编译后是否执行
delete_after=true                 # 运行后是否删除产物
declare -A extension_commands     # Extension command dictionary (保留但不使用)
declare -A extension_files        # Extension name to filename mapping (保留但不使用)

# ==============================================
# 工具函数：解析语言配置
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# 工具函数：检查命令是否安装
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# 工具函数：获取编译器版本字符串
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
            version="sh (系统默认)" ;;
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
# 工具函数：获取编译器安装建议命令
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
        *) echo "（请手动安装 $compiler）" ;;
    esac
}

# ==============================================
# 工具函数：递归查找文件
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    # 在源目录及其子目录中查找文件
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth 5 -name "$filename" -type f -print0 2>/dev/null)
    
    # 如果在当前搜索目录未找到，尝试处理Android存储路径
    # 仅在 source_dir 为明确的相对路径 "." 或 "./" 时才启用，避免扫描整个存储区
    if [[ ${#found_files[@]} -eq 0 && ( "$search_dir" == "." || "$search_dir" == "./" ) ]]; then
        # 尝试在常见的Android存储位置查找
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
    
    # 返回查找结果
    echo "${found_files[@]}"
}

# ==============================================
# 应用编译器-语言映射（用于自动初始化）
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })  # 用逗号分隔多个映射
    
    for op in "${op_list[@]}"; do
        # Check for path configuration parameters
        if [[ $op == f-* ]]; then
            source_dir="${op#f-}"
            echo "📁 源文件路径已设置: $source_dir"
        elif [[ $op == t-* ]]; then
            output_dir="${op#t-}"
            echo "📂 编译产物路径已设置: $output_dir"
        # Handle compiler-language mappings
        elif [[ $op == *-* ]]; then
            # 解析编译器-语言对
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            # 验证语言是否支持
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  不支持的语言 '$lang' (已忽略)"
                continue
            fi
            
            # 验证编译器是否在该语言的候选列表中
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  编译器 '$compiler' 不支持用于 $lang 语言 (已忽略)"
                continue
            fi
            
            # 应用配置
            lang_default_compiler[$lang]=$compiler
            echo "✅ ${lang} 语言编译器已设置为: $compiler"
            
            # 检查是否需要提示安装
            if ! is_installed "$compiler"; then
                echo "⚠️  注意: $compiler 未安装"
                case "$compiler" in
                    python3|pypy|pypy3) echo "   💡 建议安装: pkg install python" ;;
                    gcc|g++|clang|clang++) echo "   💡 建议安装: pkg install clang" ;;
                    javac) echo "   💡 建议安装: pkg install openjdk-17" ;;
                    node) echo "   💡 建议安装: pkg install nodejs" ;;
                    php) echo "   💡 建议安装: pkg install php" ;;
                    bash|sh) echo "   💡 建议安装: pkg install bash" ;;
                    gfortran) echo "   💡 建议安装: pkg install gcc-gfortran" ;;
                    rustc) echo "   💡 建议安装: pkg install rust" ;;
                    kotlinc) echo "   💡 建议安装: pkg install kotlin" ;;
                    octave) echo "   💡 建议安装: pkg install octave" ;;
                esac
            fi
        else
            echo "⚠️  未知配置 '$op' (已忽略)"
        fi
    done
}

# ==============================================
# 初始化配置流程
# ==============================================
initialize() {
    # 获取脚本所在目录作为默认路径
    local script_dir=$(dirname "$0")
    
    # 1. 配置源文件路径
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    # 处理相对路径
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  源文件路径不存在，将使用默认路径"
        source_dir=$default_source
    fi
    
    # 2. 配置编译产物路径
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    # 处理相对路径
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  编译产物路径不存在，将使用默认路径"
        output_dir=$default_output
    fi
    
    # 3. 应用默认编译器配置
    # 先设置所有语言为默认推荐
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    # 应用编译器-语言映射
    if [[ -n "$op_codes" ]]; then
        echo -e "\n🔧 应用编译器-语言映射配置..."
        apply_compiler_language_pairs "$op_codes"
    fi
    
    echo -e "\n✅ 初始化完成！"
    
    # 显示脚本位置和源目录的完整路径
    local script_full_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
    echo "📄 脚本位置: $script_full_path"
    echo "📁 源文件目录: $source_full_path"
}

# ==============================================
# 列出当前目录下的源文件并编号
# ==============================================
vls() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│     当前目录源文件列表      │"
    echo "└─────────────────────────────┘"
    
    # 存储找到的文件路径
    local found_files=()
    
    # 定义支持的文件扩展名
    local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
    
    # 在源目录及其子目录中查找文件
    for ext in "${extensions[@]}"; do
        while IFS= read -r -d '' file; do
            found_files+=("$file")
        done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
    done
    
    # 如果没有找到文件
    if [[ ${#found_files[@]} -eq 0 ]]; then
        echo "❌ 当前目录及子目录中未找到支持的源文件"
        echo "└─────────────────────────────┘"
        return 0
    fi
    
    # 显示文件列表并编号
    echo "找到 ${#found_files[@]} 个源文件:"
    echo ""
    for i in "${!found_files[@]}"; do
        local filename=$(basename "${found_files[$i]}")
        local filepath="${found_files[$i]}"
        printf "  %2d. %s\n" $((i+1)) "$filename"
    done
    echo ""
    echo "💡 输入文件编号可直接运行对应文件"
    echo "└─────────────────────────────┘"
    
    # 将文件列表存储在全局数组中供后续使用
    vls_files=("${found_files[@]}")
}

# ==============================================
# 编译执行核心逻辑
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"  # 可选：用户单次指定的编译器
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    # 1. 检查文件是否存在
    if [[ ! -f "$full_path" ]]; then
        echo "❌ 错误: 文件 '$full_path' 不存在"
        return 1
    fi
    
    # 2. 根据扩展名判断语言
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
            echo "❌ 错误: 不支持的文件类型 '$filename'"
            return 1
            ;;
    esac
    
    # 3. 确定使用的编译器
    if [[ -n "$custom_compiler" ]]; then
        # 优先使用用户单次指定的编译器
        compiler="$custom_compiler"
        echo "⚠️  单次临时使用编译器: $compiler"
    else
        # 使用该语言的默认编译器
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. 检查编译器是否安装
    if ! is_installed "$compiler"; then
        echo "❌ 错误: 编译器 '$compiler' 未安装"
        case "$compiler" in
            python3|pypy|pypy3) echo "   💡 建议安装: pkg install python" ;;
            gcc|g++|clang|clang++) echo "   💡 建议安装: pkg install clang" ;;
            javac) echo "   💡 建议安装: pkg install openjdk-17" ;;
            node) echo "   💡 建议安装: pkg install nodejs" ;;
            php) echo "   💡 建议安装: pkg install php" ;;
            bash|sh) echo "   💡 建议安装: pkg install bash" ;;
            gfortran) echo "   💡 建议安装: pkg install gcc-gfortran" ;;
            rustc) echo "   💡 建议安装: pkg install rust" ;;
            kotlinc) echo "   💡 建议安装: pkg install kotlin" ;;
            octave) echo "   💡 建议安装: pkg install octave" ;;
        esac
        return 1
    fi
    
    # 5. 执行编译运行
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        执行 $filename       │"
    echo "│ 语言: $lang | 编译器: $compiler │"
    echo "└─────────────────────────────┘"
    
    # 保存当前目录
    local original_dir=$(pwd)
    
    # 执行相应的编译/运行命令
    case "$compiler" in
        # Python 系列
        python3|pypy|pypy3)
            echo "🚀 运行 Python 脚本..."
            "$compiler" "$full_path"
            ;;
        
        # C 系列
        gcc|clang)
            local output_file="${output_dir}/$(basename "$filename" .c)"
            echo "🔨 编译 C 文件..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  已删除编译产物: $output_file"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # C++ 系列
        g++|clang++)
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            echo "🔨 编译 C++ 文件..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  已删除编译产物: $output_file"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # Java
        javac)
            local classname=$(basename "$filename" .java)
            echo "🔨 编译 Java 文件..."
            javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: ${output_dir}/${classname}.class"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    (cd "$output_dir" && java "$classname")
                    if [[ $delete_after == true ]]; then
                        rm -f "${output_dir}/${classname}.class"
                        echo "🗑️  已删除编译产物: ${classname}.class"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # Shell
        bash|sh)
            echo "🚀 运行 Shell 脚本..."
            "$compiler" "$full_path"
            ;;
        
        # JavaScript
        node)
            echo "🚀 运行 JavaScript 文件..."
            "$compiler" "$full_path"
            ;;
        
        # PHP
        php)
            echo "🚀 运行 PHP 脚本..."
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
            echo "🔨 编译 Fortran 文件..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  已删除编译产物: $output_file"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # Rust
        rustc)
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            echo "🔨 编译 Rust 文件..."
            "$compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  已删除编译产物: $output_file"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # Kotlin
        kotlinc)
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            echo "🔨 编译 Kotlin 文件..."
            "$compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 编译成功: $jar_file"
                if [[ $execute == true ]]; then
                    echo "🏃 运行程序..."
                    java -jar "$jar_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$jar_file"
                        echo "🗑️  已删除编译产物: $jar_file"
                    fi
                fi
            else
                echo "❌ 编译失败"
                cd "$original_dir"  # 返回原目录
                return 1
            fi
            ;;
        
        # Octave
        octave)
            echo "🚀 运行 Octave 脚本..."
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        # 未知编译器
        *)
            echo "❌ 错误: 不支持的编译器 '$compiler'"
            cd "$original_dir"  # 返回原目录
            return 1
            ;;
    esac
    
    # 返回原目录
    cd "$original_dir"
    
    echo "┌─────────────────────────────┐"
    echo "│        执行结束             │"
    echo "└─────────────────────────────┘"
    return 0
}

# ==============================================
# 显示可用编译器信息
# ==============================================
check_availability() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│     编译器可用性检查        │"
    echo "└─────────────────────────────┘"
    
    # 按语言名排序，输出稳定
    for lang in $(echo "${!language_config[@]}" | tr ' ' '\n' | sort); do
        local rec_compiler=$(get_default_default "$lang")
        local active_compiler="${lang_default_compiler[$lang]:-$rec_compiler}"
        local candidates=$(get_candidates "$lang")
        
        echo ""
        echo "  ${lang}"
        
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            # > 标记激活的编译器，纯 ASCII 单字符保证列对齐可靠
            if [[ "$active_compiler" == "$compiler" ]]; then
                local ptr=">"
            else
                local ptr=" "
            fi
            
            # emoji 放在 printf 外面，避免双宽字符干扰列对齐
            # 列结构: 2空格 + ptr(1列) + 1空格 + emoji(2列) + 1空格 + 编译器名(10列) + 2空格 + 信息
            local name_col=$(printf '%-10s' "$compiler")
            if is_installed "$compiler"; then
                local version=$(get_compiler_version "$compiler")
                echo "  ${ptr} ✅ ${name_col}  ${version}"
            else
                local hint=$(get_install_hint "$compiler")
                echo "  ${ptr} ❌ ${name_col}  未安装  💡 ${hint}"
            fi
        done
    done
    echo ""
    echo "└─────────────────────────────┘"
}

# ==============================================
# 主交互界面
# ==============================================
main_interface() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        主界面               │"
    echo "└─────────────────────────────┘"
    echo "📝 使用说明:"
    echo "   • 输入文件名(和编译器)单次执行"
    echo "   • 输入 'vls' 查看当前目录源文件列表"
    echo "   • 输入文件编号直接运行对应文件"
    echo "   • 按 Ctrl+C 退出并显示配置种子"
    echo "└─────────────────────────────┘"
    
    # 全局数组存储vls命令列出的文件
    local vls_files=()
    
    while true; do
        # Get source directory for display (last 2 levels)
        local source_dir_display=$(format_path_for_display "$source_dir")
        read -p "🟢[colL] $source_dir_display ❯ " -a input
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
            # 检查特殊命令
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
                # 更新vls_files数组以便数字输入可以使用
                vls_files=()
                local extensions=("*.c" "*.cpp" "*.cxx" "*.cc" "*.java" "*.py" "*.sh" "*.js" "*.php" "*.m" "*.f" "*.f90" "*.f95" "*.f03" "*.f08" "*.rs" "*.kt")
                for ext in "${extensions[@]}"; do
                    while IFS= read -r -d '' file; do
                        vls_files+=("$file")
                    done < <(find "$source_dir" -name "$ext" -type f -print0 2>/dev/null)
                done
                continue
            fi
            
            # 检查是否为数字输入（文件编号）
            if [[ "${input[0]}" =~ ^[0-9]+$ ]]; then
                # 检查是否有文件列表
                if [[ ${#vls_files[@]} -eq 0 ]]; then
                    echo "❌ 错误: 请先运行 'vls' 命令查看文件列表"
                    continue
                fi
                
                local selection=${input[0]}
                if [[ $selection -lt 1 || $selection -gt ${#vls_files[@]} ]]; then
                    echo "❌ 错误: 无效的文件编号 (请输入 1-${#vls_files[@]} 之间的数字)"
                    continue
                fi
                
                local selected_file="${vls_files[$((selection-1))]}"
                local compiler="${input[1]}"  # 可选的编译器参数
                echo "📁 运行文件: $(basename "$selected_file")"
                execute_file "$selected_file" "$compiler"
                continue
            fi
            
            # 解析用户输入
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            # 前置校验：必须是支持的文件扩展名，否则立即报错，不走 find
            case "$filename" in
                *.c|*.cpp|*.cxx|*.cc|*.java|*.py|*.sh|*.js|*.php|*.m|*.f|*.f90|*.f95|*.f03|*.f08|*.rs|*.kt)
                    : # 合法扩展名，继续
                    ;;
                *)
                    echo "❌ 未知命令或不支持的文件类型: '$filename'"
                    echo "   💡 输入 '--help' 查看帮助，输入 'vls' 列出源文件"
                    continue
                    ;;
            esac
            
            # Recursively find file
            local found_files=($(find_file_recursive "$filename" "$source_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                # Show full path in error message
                local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
                echo "❌ 错误: 在 '${source_full_path}' 及其子目录中未找到文件 '$filename'"
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 找到多个名为 '$filename' 的文件:"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 请选择要执行的文件序号: " selection
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ 错误: 无效的序号"
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
# 主函数
# ==============================================
main() {
    echo ""
    echo "┌─────────────────────────────┐"
    echo "│        colL v$VERSION         │"
    echo "│ 多语言编译运行工具 (轻量版) │"
    echo "└─────────────────────────────┘"
    echo "👋 欢迎使用 colL！"
    echo "   • 输入 '--help' 获取帮助"
    echo "   • 输入 'vls' 查看源文件列表"
    echo "   • 输入 'checkavails' 查看编译器状态"
    echo "└─────────────────────────────┘"
    
    # 从命令行参数加载种子配置
    load_seed_from_args "$@"
    
    # 初始化配置
    initialize
    
    # 进入主界面
    main_interface
}

# 启动程序
main "$@"