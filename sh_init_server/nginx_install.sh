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

function install_nginx() {
    log_info "${NGINX} Installing Nginx"

    sudo apt update
    sudo apt install -y nginx

    if nginx -v; then
        log_success "${NGINX} Nginx installed successfully!"
    else
        log_error "${NGINX} Nginx installation failed."
        exit 1
    fi
}

function setting_nginx() {
    log_info "${NGINX} Configuring Nginx and SSL certificates..."

    # Xóa file cấu hình mặc định của Nginx nếu có
    sudo rm -rf /etc/nginx/sites-enabled/default

    # Tạo thư mục chứa chứng chỉ SSL
    sudo mkdir -p /etc/nginx/ssl

    # Yêu cầu nhập tên miền bằng hàm log_prompt vừa tạo
    log_prompt "${NGINX} Enter your domain name (e.g., example.com): "
    read -r DOMAIN_NAME

    if [ -z "$DOMAIN_NAME" ]; then
        log_error "Domain name cannot be empty."
        exit 1
    fi

    # Nhập nội dung file CRT
    log_info "${NGINX} Please paste your SSL Certificate (.crt) content below."
    log_info "${NGINX} Press Ctrl+D on a new line when you are finished:"
    sudo tee "/etc/nginx/ssl/${DOMAIN_NAME}.crt" > /dev/null

    # Nhập nội dung file KEY
    log_info "${NGINX} Please paste your SSL Private Key (.key) content below."
    log_info "${NGINX} Press Ctrl+D on a new line when you are finished:"
    sudo tee "/etc/nginx/ssl/${DOMAIN_NAME}.key" > /dev/null

    log_success "${NGINX} SSL certificates configured successfully for ${DOMAIN_NAME}!"
}

install_nginx
setting_nginx
