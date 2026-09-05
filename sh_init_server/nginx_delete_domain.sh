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

function delete_domain() {
    log_info "${NGINX} Listing active Nginx virtual hosts..."
    
    # Hiển thị danh sách các site đang bật để người dùng dễ nhìn thấy tên file cần xóa
    ls -la /etc/nginx/sites-enabled/

    # Yêu cầu nhập tên miền cần xóa
    log_prompt "${NGINX} Enter the domain name to delete (e.g., sub.example.com): "
    read -r DOMAIN_NAME

    if [ -z "$DOMAIN_NAME" ]; then
        log_error "${NGINX} Domain name cannot be empty."
        exit 1
    fi

    # Tiến hành xóa đồng thời file cấu hình ở sites-available và symlink ở sites-enabled
    log_info "${NGINX} Removing configuration files for '${DOMAIN_NAME}'..."
    sudo rm -f "/etc/nginx/sites-available/${DOMAIN_NAME}.conf"
    sudo rm -f "/etc/nginx/sites-enabled/${DOMAIN_NAME}.conf"

    # Kiểm tra tính hợp lệ của cấu hình Nginx sau khi xóa
    log_info "${NGINX} Testing Nginx configuration syntax..."
    if sudo nginx -t; then
        log_success "${NGINX} Nginx configuration test passed successfully!"
    else
        log_error "${NGINX} Nginx configuration syntax error detected."
        exit 1
    fi

    # Reload lại Nginx để áp dụng thay đổi
    log_info "${NGINX} Reloading Nginx service..."
    if sudo systemctl reload nginx; then
        log_success "${NGINX} Domain '${DOMAIN_NAME}' has been deleted and Nginx reloaded successfully!"
    else
        log_error "${NGINX} Failed to reload Nginx service."
        exit 1
    fi
}

delete_domain