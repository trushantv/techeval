#!/bin/bash
set -e

# Install MongoDB 4.4 (intentionally outdated)
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

apt-get update -y
apt-get install -y mongodb-org=4.4.29 mongodb-org-server=4.4.29 mongodb-org-shell=4.4.29 mongodb-org-mongos=4.4.29 mongodb-org-tools=4.4.29

# Start and enable MongoDB
systemctl start mongod
systemctl enable mongod

# Wait for MongoDB to be ready
sleep 10

# Create admin user with authentication
mongo --eval "
db = db.getSiblingDB('admin');
db.createUser({
  user: '${mongodb_username}',
  pwd: '${mongodb_password}',
  roles: [{ role: 'root', db: 'admin' }]
});
"

# Enable authentication in MongoDB config
sed -i 's/#security:/security:\n  authorization: enabled/' /etc/mongod.conf

# Bind to all interfaces so EKS pods can connect
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Restart to apply config changes
systemctl restart mongod

# Install AWS CLI for S3 backups
apt-get install -y awscli

# Create daily MongoDB backup script
cat > /usr/local/bin/mongodb-backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y-%m-%d-%H%M)
BACKUP_DIR="/tmp/mongodb-backup-$DATE"

mongodump \
  --username "${mongodb_username}" \
  --password "${mongodb_password}" \
  --authenticationDatabase admin \
  --out "$BACKUP_DIR"

tar -czf "$BACKUP_DIR.tar.gz" -C /tmp "mongodb-backup-$DATE"

aws s3 cp "$BACKUP_DIR.tar.gz" "s3://${s3_bucket}/backups/mongodb-backup-$DATE.tar.gz" --region ${aws_region}

rm -rf "$BACKUP_DIR" "$BACKUP_DIR.tar.gz"
EOF

chmod +x /usr/local/bin/mongodb-backup.sh

# Schedule daily backup at 2am via cron
echo "0 2 * * * root /usr/local/bin/mongodb-backup.sh >> /var/log/mongodb-backup.log 2>&1" >> /etc/crontab
