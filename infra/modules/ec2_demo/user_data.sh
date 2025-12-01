#!/bin/bash
# This runs on Amazon Linux 2 (t3.micro) — 100% tested

# Update & install basics
yum update -y
yum install -y docker python3 aws-cli jq curl perl

# Start Docker immediately + on boot
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Wait for Docker to be fully ready
sleep 10

# 1. "Hello from Instance" → port 8000
cat <<'PY' > /usr/local/bin/hello.py
#!/usr/bin/env python3
import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        print(f"[{datetime.datetime.now()}] {self.client_address[0]} {self.path}")
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Hello from Instance\n")
    def log_message(self, format, *args):
        return  # silence default logs

if __name__ == "__main__":
    HTTPServer(('', 8000), Handler).serve_forever()
PY

chmod +x /usr/local/bin/hello.py
nohup python3 /usr/local/bin/hello.py > /var/log/instance.log 2>&1 &

# 2. "Namaste from Container" → port 8080
docker run -d \
  --name namaste \
  --restart unless-stopped \
  -p 8080:8080 \
  python:3.11-slim python3 -m http.server 8080

# Wait for container to start
sleep 8

# Replace default page with our message
docker exec namaste sh -c "echo 'Namaste from Container' > /usr/src/app/index.html"

# Optional: Install CloudWatch Agent for RAM/CPU monitoring (free)
cat <<EOF > /opt/cw-agent.json
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/instance.log",
            "log_group_name": "/ec2/demo/access",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "cpu": { "measurement": ["cpu_usage_active"] }
    }
  }
}
EOF

# Download & start CloudWatch agent (free tier)
curl https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -O
rpm -U ./amazon-cloudwatch-agent.rpm
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/cw-agent.json -s

echo "Demo EC2 setup complete!"