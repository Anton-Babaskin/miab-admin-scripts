👋 Hi, I’m Anton Babaskin (@z3r0-gr4v1tY)  
🧠 System Engineer / Infrastructure Architect focused on Linux-first environments, mail systems, virtualisation, monitoring and automation.  
🌍 I manage distributed systems for trading/enterprise teams — and build tools to make admin life easier.

# 🛠️ Mail-in-a-Box Scripts

A personal collection of Bash scripts I use to streamline, secure, and monitor **Mail-in-a-Box (MIAB)** servers in production.  
Everything here is field-tested in real-world infrastructure (multi-domain, Postgrey, SFTP/WebDAV backups, Telegram alerts).

> 🧰 All scripts were written from scratch and adapted to suit the needs of live mail infrastructure across several companies.

📦 What’s Inside:

### 📁 backup_sftp.sh  
🔄 Backup the `/home/user-data` directory to a remote **SFTP server**, with logging and optional rotation.  
🗄️ Ideal for off-site backups via key-authenticated SFTP targets.  
🧹 Automatically removes old archives from the remote server.  
📲 Sends success/failure alerts to your Telegram bot (optional).
#### ⚙️ Configuration
```bash
SFTP_USER="your_sftp_username"
SFTP_HOST="your.sftp.server"
SFTP_PORT=22
SFTP_DIR="/backups/$(hostname)"
SOURCE_DIR="/home/user-data"

BOT_TOKEN="your_telegram_bot_token"   # Optional
CHAT_ID="your_telegram_chat_id"       # Optional
```
### 💡Examples of use:
Create a backup and upload it to an SFTP server:
```bash
chmod +x backup_sftp.sh
./backup_sftp.sh
```
An archive named backup-YYYY-MM-DD_HH-MM-SS.tar.gz will be created in the temporary folder, uploaded to the specified SFTP server, and deleted locally. If BOT_TOKEN and CHAT_ID are set, the script will send a notification to Telegram.

### ☁️ backup_restic_webdav.sh
💾 Performs secure, incremental backups using Restic + Rclone to a WebDAV-compatible cloud storage (e.g. Hetzner Storage Box).
🔐 All data is encrypted client-side using a strong password.
🧹 Supports snapshot pruning (daily/weekly/monthly).
📲 Sends status to Telegram (optional).
🕒 Easily schedulable via cron.

⚙️ Configuration

 ```bash
RCLONE_REMOTE="your_rclone_remote:your/path"
RESTIC_PASSWORD="your_secure_restic_password"

BOT_TOKEN="your_telegram_bot_token"   # Optional
CHAT_ID="your_telegram_chat_id"       # Optional

BACKUP_SOURCE="/home/user-data"
 ```
### 💡Examples of use:
 ```bash
chmod +x restic_rclone_webdav.sh
./restic_rclone_webdav.sh
```
The script creates an encrypted Restic backup of the /home/user-data directory using rclone to sync with a remote WebDAV storage.

If BOT_TOKEN and CHAT_ID are set, the script will also send a success/failure status message to Telegram.

### 🕵️ postgrey_notify_telegram.sh
Monitors Postgrey greylisting events and sends real-time alerts to a Telegram bot.
🔔 Sends two types of alerts:
⚠️ When a sender is greylisted
✅ When the same sender later successfully delivers a message
🧠 Prevents duplicate alerts by tracking sender IPs.

⚙️ Configuration
 ```bash
LOG_FILE="/var/log/mail.log"
BOT_TOKEN="your_telegram_bot_token"
CHAT_ID="your_telegram_chat_id"
Internal state files used:

/var/lib/postgrey-seen.log — already notified greylist entries

/var/lib/postgrey-passed.log — IPs that passed greylisting
 
🕒 Cron example

*/2 * * * * /path/to/postgrey_notify_telegram.sh
📲 Telegram messages


⚠️ New greylisted sender:
postgrey[1234]: delayed SMTP connection from mail.example.com[192.100.200.77]

✅ Greylisted sender passed:
192.100.200.77
Message successfully delivered.
```

```bash
chmod +x postgrey_notify_telegram.sh
./postgrey_notify_telegram.sh
```
The script saves already processed entries to /var/tmp/postgrey-notify.state and only sends new greylisted IP addresses to Telegram.

⚙️ Requirements

```bash
✅ Mail-in-a-Box v60+
🐧 Linux (Ubuntu recommended)
🛠️ Tools: bash, curl, jq, grep, awk
🔐 restic, rclone — for WebDAV/cloud backups
🤖 Telegram Bot Token + Chat ID (for notifications)
⏲️ cron (optional, for scheduled tasks)
```
📄 License
🆓 MIT License — free to use, fork, modify.
🤝 Contributions welcome!

❗ Disclaimer
These scripts are provided as-is.
Use with caution — especially in production environments. Always test first.


Custom tooling by Anton Babaskin, 2025. Inspired by best practices.
