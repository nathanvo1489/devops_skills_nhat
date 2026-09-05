```bash
sudo systemctl status jenkins
sudo systemctl start jenkins
sudo systemctl stop jenkins

sudo update-alternatives --config editor

sudo systemctl edit jenkins
```

### Anything between here and the comment below will become the contents...
```text
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/var/cache/jenkins/tmp/"
Environment="JENKINS_OPTS=--pluginroot=/var/cache/jenkins/plugins"
```
### Edits below this comment will be discarded


Tạo folder và set user
```bash
sudo mkdir -p /var/cache/jenkins/tmp
sudo chown -R jenkins:jenkins /var/cache/jenkins/tmp

sudo mkdir -p /var/cache/jenkins/plugins
sudo chown -R jenkins:jenkins /var/cache/jenkins/plugins

# kiểm tra tính hợp lệ của file cấu hình
systemd-analyze verify jenkins.service
```