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

JENKINS="[JENKINS]"

function installation_of_java() {
    log_info "${JENKINS} Installing Java"

    sudo apt update &>/dev/null
    sudo apt install -y fontconfig openjdk-21-jre

    log_info "${JENKINS} Verifying Java installation..."
    if java -version; then
        log_success "${JENKINS} Java installed successfully!"
    else
        log_error "${JENKINS} Java installation or verification failed."
        exit 1
    fi
}

function long_term_support_release() {
    log_info "${JENKINS} Installing Jenkins"

    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
        https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
        https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list >/dev/null
    sudo apt update
    sudo apt install -y jenkins

    log_success "${JENKINS} Jenkins LTS installed successfully!"
}

function setting_jenkins() {
    log_info "${JENKINS} Stopping Jenkins service..."
    if sudo systemctl stop jenkins; then
        log_success "${JENKINS} Jenkins service stopped successfully."
    else
        log_error "${JENKINS} Failed to stop Jenkins service."
        exit 1
    fi

    log_info "${JENKINS} Adding 'jenkins' user to the 'docker' group..."
    if sudo usermod -aG docker jenkins; then
        log_success "${JENKINS} User 'jenkins' successfully added to the 'docker' group."
    else
        log_error "${JENKINS} Failed to add 'jenkins' to the 'docker' group."
        exit 1
    fi

    # Cấu hình biến môi trường Java và Jenkins
    log_info "${JENKINS} Configuring Jenkins systemd environment options..."
    sudo mkdir -p /etc/systemd/system/jenkins.service.d

    sudo tee /etc/systemd/system/jenkins.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/var/cache/jenkins/tmp/"
Environment="JENKINS_OPTS=--pluginroot=/var/cache/jenkins/plugins"
EOF

    log_success "${JENKINS} Jenkins environment override configuration applied."

    # Tạo thư mục cache và phân quyền cho user jenkins
    log_info "${JENKINS} Creating and setting permissions for Jenkins cache directories..."
    sudo mkdir -p /var/cache/jenkins/tmp
    sudo chown -R jenkins:jenkins /var/cache/jenkins/tmp

    sudo mkdir -p /var/cache/jenkins/plugins
    sudo chown -R jenkins:jenkins /var/cache/jenkins/plugins
    log_success "${JENKINS} Jenkins cache and plugin directories initialized."

    # Kiểm tra tính hợp lệ của cấu hình systemd
    log_info "${JENKINS} Verifying systemd configuration..."
    if sudo systemd-analyze verify jenkins.service; then
        log_success "${JENKINS} Systemd configuration is valid."
    else
        log_error "${JENKINS} Systemd configuration validation failed."
        exit 1
    fi

    # Reload systemd manager và khởi động lại Jenkins
    log_info "${JENKINS} Reloading systemd daemon Jenkins..."
    sudo systemctl daemon-reload
    
    log_info "${JENKINS} Starting Jenkins..."
    if sudo systemctl start jenkins; then
        log_success "${JENKINS} Jenkins started successfully!"
    else
        log_error "${JENKINS} Failed to start Jenkins service."
        exit 1
    fi
}

installation_of_java
long_term_support_release
setting_jenkins
