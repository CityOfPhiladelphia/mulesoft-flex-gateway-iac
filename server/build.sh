export APP_NAME=$1
export ENV_NAME=$2
# Set hostname to `app-env-{old hostname}`
sudo hostnamectl hostname "${APP_NAME}-${ENV_NAME}-$(hostnamectl hostname)"
# Make sure we are in the "server" folder
cd ~/mulesoft-iac/server
# This script is to be run as ec2-user, not as root
# Install docker, nginx, and cronie
sudo dnf install -y docker nginx cronie
# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user
# Start docker, nginx, crond
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start crond
sudo systemctl enable crond
# Copy registration from s3
export S3_NAME=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/s3_name" --query "Parameter.Value" --output text)
export REGISTRATION_S3_KEY=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/registration_s3_key" --query "Parameter.Value" --output text)
aws s3 cp s3://$S3_NAME/$REGISTRATION_S3_KEY flex-gateway/conf/registration.yaml
# Run all these commands as ec2-user (required because it establishes new docker group)
sudo -u ec2-user --preserve-env=APP_NAME,ENV_NAME -i <<'EOF'
cd ~/mulesoft-iac/server/flex-gateway
bash run-flex-gateway.sh
EOF

# Set up cron health check
sudo mv flex-gateway/health-check.sh /root/health-check.sh
sudo chmod u+x /root/health-check.sh
echo "* * * * * root /root/health-check.sh" | sudo tee /etc/cron.d/flex-gateway-health-check

# Good! Flex gateway should be up and running, time to install grafana alloy for monitoring
# Alloy cannot be installed until its gpg key is imported
wget -q -O gpg.key https://rpm.grafana.com/gpg.key
sudo rpm --import gpg.key
echo -e '[grafana]\nname=grafana\nbaseurl=https://rpm.grafana.com\nrepo_gpgcheck=1\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.grafana.com/gpg.key\nsslverify=1\nsslcacert=/etc/pki/tls/certs/ca-bundle.crt' | sudo tee /etc/yum.repos.d/grafana.repo
# Install alloy
sudo yum update -y
sudo dnf install -y alloy
# Copy our config into the right file
sudo cp alloy/config.alloy.hcl /etc/alloy/config.alloy
# Get environment variables for alloy
export LOKI_USER=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/loki_user" --with-decryption --query "Parameter.Value" --output text)
export LOKI_PASSWORD=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/loki_pw" --with-decryption --query "Parameter.Value" --output text)
export PROMETHEUS_USER=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/prometheus_user" --with-decryption --query "Parameter.Value" --output text)
export PROMETHEUS_PASSWORD=$(aws ssm get-parameter --name "/$APP_NAME/$ENV_NAME/prometheus_pw" --with-decryption --query "Parameter.Value" --output text)
# Write them to alloy's env file
echo "LOKI_USER=$LOKI_USER" | sudo tee -a /etc/sysconfig/alloy >/dev/null
echo "LOKI_PASSWORD=$LOKI_PASSWORD" | sudo tee -a /etc/sysconfig/alloy >/dev/null
echo "PROMETHEUS_USER=$PROMETHEUS_USER" | sudo tee -a /etc/sysconfig/alloy >/dev/null
echo "PROMETHEUS_PASSWORD=$PROMETHEUS_PASSWORD" | sudo tee -a /etc/sysconfig/alloy >/dev/null
# Start alloy!
sudo systemctl start alloy
sudo systemctl enable alloy.service
