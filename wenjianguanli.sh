#!/bin/bash

# Maximum log file size in bytes (2MB)
MAX_LOG_SIZE=$((2 * 1024 * 1024))

# 检查目录是否存在，不存在则创建
function check_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# 日志记录函数
function log_action() {
    local log_file="/storage/emulated/0/下载/文件整理日志.txt"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
    truncate_log_file "$log_file"
}

# 检查并截断日志文件
function truncate_log_file() {
    local log_file="$1"
    local log_size=$(stat -c%s "$log_file")

    if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
        tail -c "$MAX_LOG_SIZE" "$log_file" > "$log_file.tmp"
        mv "$log_file.tmp" "$log_file"
    fi
}

# 移动文件并分类
function move_files() {
    local src_dir="$1"
    if [ ! -d "$src_dir" ]; then
        echo "路径 $src_dir 不存在，跳过。"
        log_action "路径 $src_dir 不存在，跳过。"
        return
    fi

    find "$src_dir" -maxdepth 1 -type f | while read -r file; do
        filename=$(basename "$file")
        extension="${filename##*.}"
        extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        case "$extension_lower" in
            # 压缩包
            zip|rar|7z|tar|gz|bz2|xz|tar.gz|tar.bz2|tar.xz)
                destination="/storage/emulated/0/下载/压缩包/"
                ;;
            # 图片
            png|jpg|jpeg|gif|bmp|tiff|svg|webp|heic|heif)
                destination="/storage/emulated/0/下载/图片/"
                ;;
            # 软件
            apk|exe|msi|deb|rpm|dmg|pkg|appimage|bat|sh)
                destination="/storage/emulated/0/下载/软件/"
                ;;
            # 视频
            mp4|avi|mov|wmv|flv|mkv|webm|vob|rmvb|3gp|ts|m4v)
                destination="/storage/emulated/0/下载/视频/"
                ;;
            # 文档
            doc|docx|pdf|xls|xlsx|ppt|pptx|odt|ods|odp|rtf)
                destination="/storage/emulated/0/下载/文档/"
                ;;
            # 音频
            mp3|wav|flac|aac|ogg|m4a|wma|alac|ape)
                destination="/storage/emulated/0/下载/音频/"
                ;;
            # 文本
            txt|log|md|json|xml|csv|yaml|yml|ini|conf|cfg)
                destination="/storage/emulated/0/下载/文本/"
                ;;
            # 脚本和代码
            sh|py|js|html|htm|css|php|java|c|cpp|h|hpp|go|rb|pl|lua|swift|kt|cs|ts|sql|R|r|ipynb)
                destination="/storage/emulated/0/下载/代码/"
                ;;
            # 磁力链接文件
            torrent|magnet)
                destination="/storage/emulated/0/下载/种子/"
                ;;
            # 光盘镜像
            iso|img|bin|cue|nrg|mdf|mds|dmg)
                destination="/storage/emulated/0/下载/镜像文件/"
                ;;
            # 字体文件
            ttf|otf|fon|woff|woff2|eot)
                destination="/storage/emulated/0/下载/字体/"
                ;;
            # 数据库文件
            db|sql|sqlite|mdb|accdb|dbf)
                destination="/storage/emulated/0/下载/数据库/"
                ;;
            # 电子书
            epub|mobi|azw3|djvu|fb2|ibooks|chm)
                destination="/storage/emulated/0/下载/电子书/"
                ;;
            # 压缩音乐
            zipx|rar|7z|flac|ape)
                destination="/storage/emulated/0/下载/无损音乐/"
                ;;
            # PSD 文件
            psd|ai|eps|indd)
                destination="/storage/emulated/0/下载/设计文件/"
                ;;
            # 应用数据
            plist|mobileconfig|cer|crt|pem|der)
                destination="/storage/emulated/0/下载/应用数据/"
                ;;
            # 备份文件
            bak|backup|bk)
                destination="/storage/emulated/0/下载/备份文件/"
                ;;
            # 临时文件
            tmp|temp|swp|swo|dmp)
                destination="/storage/emulated/0/下载/临时文件/"
                ;;
            # 其他
            *)
                destination="/storage/emulated/0/下载/其他/"
                ;;
        esac

        check_dir "$destination"

        if [ -e "$destination/$filename" ]; then
            # 如果目标文件已存在，避免覆盖，重新命名文件
            base="${filename%.*}"
            suffix=1
            while [ -e "$destination/${base}_$suffix.$extension}" ]; do
                suffix=$((suffix + 1))
            done
            new_filename="${base}_$suffix.$extension}"
        else
            new_filename="$filename"
        fi

        mv "$file" "$destination/$new_filename"
        log_action "已移动文件 $file 到 $destination/$new_filename"
        echo "已移动文件 $file 到 $destination/$new_filename"
    done
}

# 主目录检查
check_dir "/storage/emulated/0/下载/"

# 定义需要处理的路径列表
paths=(
    "/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/"
    "/storage/emulated/0/Download/WeiXin/"
    "/storage/emulated/999/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/"
    "/storage/emulated/0/Android/data/tw.nekomimi.nekogram/files/Telegram/Telegram Video/"
    "/storage/emulated/0/Android/data/tw.nekomimi.nekogram/files/Telegram/Telegram Images/"
    "/storage/emulated/0/Download/BaiduNetdisk/"
    "/storage/emulated/0/123云盘/Cache/"
    "/storage/emulated/0/Download/"
    "/storage/emulated/0/Pictures/图叨叨/"
    "/storage/emulated/0/Pictures/douyin/"
    "/storage/emulated/0/Pictures/WeiXin/"
    "/storage/emulated/0/Pictures/"
    "/storage/emulated/0/Pictures/DownloadPicture/"
    "/storage/emulated/0/Download/Nekogram/"
    "/storage/emulated/0/Download/QuarkDownloads/"
    "/storage/emulated/0/Wenshushu/Download/"
    "/storage/emulated/0/IDM/"
    "/storage/emulated/0/IDMP/Compressed/"
    "/storage/emulated/0/Download/advanced/Magisk模块/"
    "/storage/emulated/0/AliYunPan/资源库/来自分享/"
    "/storage/emulated/0/Android/data/tornaco.apps.shortx/files/"
    "/storage/emulated/0/Download/Browser/"
    "/storage/emulated/0/Android/data/com.coolapk.market/files/Download/"
    "/storage/emulated/0/Android/data/tw.nekomimi.nekogram/files/Telegram/Telegram Files/"
    # 新增路径，可以在此添加
)

# 处理每个路径
for path in "${paths[@]}"; do
    move_files "$path"
done

# 处理 /storage/emulated/0/Download/ 和 /storage/emulated/0/Pictures/ 下的所有子目录
function move_files_recursive() {
    local parent_dir="$1"
    if [ ! -d "$parent_dir" ]; then
        echo "路径 $parent_dir 不存在，跳过。"
        log_action "路径 $parent_dir 不存在，跳过。"
        return
    fi

    find "$parent_dir" -type f | while read -r file; do
        # 与 move_files 函数中的处理方式相同
        filename=$(basename "$file")
        extension="${filename##*.}"
        extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        # 重复使用之前的分类逻辑
        # ...（这里可重复使用之前的 case 语句）

        # 为了避免重复代码，可以将分类逻辑封装成一个函数
        classify_and_move "$file"
    done
}

# 分类和移动文件的函数，避免重复代码
function classify_and_move() {
    local file="$1"
    filename=$(basename "$file")
    extension="${filename##*.}"
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    case "$extension_lower" in
        # ...（与之前的 case 语句相同）
    esac

    check_dir "$destination"

    if [ -e "$destination/$filename" ]; then
        base="${filename%.*}"
        suffix=1
        while [ -e "$destination/${base}_$suffix.$extension}" ]; do
            suffix=$((suffix + 1))
        done
        new_filename="${base}_$suffix.$extension}"
    else
        new_filename="$filename"
    fi

    mv "$file" "$destination/$new_filename"
    log_action "已移动文件 $file 到 $destination/$new_filename"
    echo "已移动文件 $file 到 $destination/$new_filename"
}

# 对指定目录进行递归处理
move_files_recursive "/storage/emulated/0/Download/"
move_files_recursive "/storage/emulated/0/Pictures/"