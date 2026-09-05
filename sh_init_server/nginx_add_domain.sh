#!/bin/bash

COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;34m"    # Xanh dương (Tiêu đề bước)
COLOR_SUCCESS="\033[1;32m" # Xanh lá (Thành công)
COLOR_ERROR="\033[1;31m"   # Đỏ (Lỗi)
COLOR_PROMPT="\033[1;33m"  # Vàng (Hỏi thông tin)

log_info() {
    echo -e "\n${COLOR_INFO}===> $1${COLOR_RESET}"
}

log_success() {
    echo -e "${COLOR_SUCCESS}[✔] $1${COLOR_RESET}"
}

log_error() {
    echo -e "${COLOR_ERROR}[✖] $1${COLOR_RESET}"
}

log_prompt() {
    echo -ne "${COLOR_PROMPT}===> $1${COLOR_RESET}"
}

NGINX="[NGINX]"

function add_domain() {
    log_info "${NGINX} Starting Nginx virtual host configuration..."

    # Yêu cầu nhập tên miền bằng hàm log_prompt
    log_prompt "${NGINX} Enter your domain name (e.g., sub.example.com): "
    read -r DOMAIN_NAME

    if [ -z "$DOMAIN_NAME" ]; then
        log_error "${NGINX} Domain name cannot be empty."
        exit 1
    fi

    # Nhập nội dung file cấu hình vhost
    log_info "${NGINX} Please paste your Nginx configuration content for '${DOMAIN_NAME}.conf' below."
    log_info "${NGINX} Press Ctrl+D on a new line when you are finished:"
    sudo tee "/etc/nginx/sites-available/${DOMAIN_NAME}.conf" > /dev/null

    # Tạo symbolic link sang sites-enabled
    log_info "${NGINX} Enabling virtual host via symbolic link..."
    sudo ln -sf "/etc/nginx/sites-available/${DOMAIN_NAME}.conf" "/etc/nginx/sites-enabled/"

    # Kiểm tra tính hợp lệ của cấu hình Nginx
    log_info "${NGINX} Testing Nginx configuration syntax..."
    if sudo nginx -t; then
        log_success "${NGINX} Nginx configuration test passed successfully!"
    else
        log_error "${NGINX} Nginx configuration syntax error detected. Please check your file."
        exit 1
    fi

    # Reload lại Nginx để áp dụng thay đổi
    log_info "${NGINX} Reloading Nginx service..."
    if sudo systemctl reload nginx; then
        log_success "${NGINX} Domain '${DOMAIN_NAME}' configured and Nginx reloaded successfully!"
    else
        log_error "${NGINX} Failed to reload Nginx service."
        exit 1
    fi
}

add_domain