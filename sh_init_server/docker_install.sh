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

DOCKER="[DOCKER]"

function uninstall_old_versions() {
    log_info "${DOCKER} Uninstall old versions"

    sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

    log_success "${DOCKER} Uninstall old versions Successfully"
}

function install_apt_repository() {
    log_info "${DOCKER} Install using the apt repository"

    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update

    log_success "${DOCKER} Install using the apt repository Successfully"
}

function install_the_docker_packages() {
    log_info "${DOCKER} Install the Docker packages"

    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log_success "${DOCKER} Install the Docker packages Successfully"
}

function add_user_ubuntu_into_docker() {
    log_info "${DOCKER} Adding user 'ubuntu' to the 'docker' group..."

    if sudo usermod -aG docker ubuntu; then
        log_success "${DOCKER} User 'ubuntu' successfully added to the 'docker' group."
    else
        log_error "${DOCKER} Failed to add user 'ubuntu' to the 'docker' group."
        exit 1
    fi

    # Dùng lệnh 'sg' để ép chạy lệnh docker với nhóm docker ngay lập tức mà không bị treo
    log_info "${DOCKER} Verifying Docker permissions for the current session..."
    if sg docker -c "docker ps"; then
        log_success "${DOCKER} Docker environment is verified and ready to use!"
    else
        log_error "${DOCKER} Docker verification failed. Group permissions will fully apply on your next login."
        exit 1
    fi
}

uninstall_old_versions
install_apt_repository
install_the_docker_packages
add_user_ubuntu_into_docker
