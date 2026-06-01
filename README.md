# Cross-Platform MySQL Backup Pipeline

Automated MySQL backup solution using Linux Shell Script, Samba (SMB), Windows Batch automation and OneDrive synchronization.

---

## Overview

This project implements a complete cross-platform backup pipeline with the following workflow:

```text
MySQL (Docker)
      ↓
Shell Script (Linux)
      ↓
SQL Backup
      ↓
Samba Share (SMB)
      ↓
Windows Batch
      ↓
OneDrive Sync
      ↓
Logs & Monitoring
```

---

## Technologies

* Linux
* Shell Script (Bash)
* MySQL / mysqldump
* Docker
* Samba (SMB)
* Windows Batch
* Robocopy
* Windows Task Scheduler
* OneDrive

---

## Features

* Automated MySQL backup generation
* Scheduled execution using Cron
* SMB/Samba file sharing
* Cross-platform file transfer
* Windows Batch automation
* OneDrive synchronization
* Execution logging
* Error tracking
* Processed file management

---

## Project Structure

```text
cross-platform-backup-pipeline/
├── linux/
│   └── backup_mysql.sh
├── windows/
│   └── backup_onedrive.bat
├── logs/
├── processados/
├── erros/
└── README.md
```

---

# Linux - Backup Generation

## Objective

Generate automated MySQL backups in `.sql` format and make them available through a shared SMB/Samba directory.

### Backup Directory

```text
/home/user/mysql-backup-pipeline/
```

### Install MySQL Client

```bash
sudo apt update
sudo apt install mysql-client -y
```

### Backup Script

Location:

```text
/home/user/mysql-backup-pipeline/backup_mysql.sh
```

Main responsibilities:

* Generate MySQL dumps
* Store execution logs
* Measure execution time
* Transfer credentials into the Docker container
* Save generated backup files

### Execution Permission

```bash
chmod +x /home/user/mysql-backup-pipeline/backup_mysql.sh
```

### Cron Scheduling

Edit crontab:

```bash
crontab -e
```

Example:

```cron
00 21 * * 1-5 /bin/bash /home/user/mysql-backup-pipeline/backup_mysql.sh >> /home/user/mysql-backup-pipeline/logs/backup.log 2>&1
```

Runs every weekday at 21:00.

---

## Samba (SMB) Configuration

### Installation

```bash
sudo apt install samba -y
```

### Configuration

File:

```text
/etc/samba/smb.conf
```

Example:

```ini
[shared_backup]
path = /home/user/shared_backup
read only = no
browseable = yes
guest ok = yes
force user = root
```

### Restart Service

```bash
sudo systemctl restart smbd
```

### Windows Access

```text
\\LINUX_SERVER\shared_backup
```

---

# Windows - Automation and OneDrive Synchronization

## Objective

* Capture SQL backups from SMB share
* Copy files to OneDrive
* Move processed files
* Generate logs
* Track errors
* Automate execution using Task Scheduler

---

## Directory Structure

```text
C:\Backup_mysql_portal
├── scripts
│   └── backup_onedrive.bat
├── logs
├── processados
└── erros
```

---

## Network Mapping

```bat
net use Z: \\LINUX_SERVER\shared_backup
```

---

## OneDrive Destination

```text
C:\Users\<user>\OneDrive - CorporateAccount\DatabaseBackups
```

---

## Batch Workflow

### 1. Initialization

* Create logs
* Define variables
* Validate directories

### 2. Network Connection

```bat
net use Z: /delete /y
net use Z: \\LINUX_SERVER\shared_backup
```

### 3. OneDrive Write Test

```bat
echo teste > "%DESTINO%\_teste_write.txt"
```

### 4. File Copy

```bat
robocopy "%ORIGEM%" "%DESTINO%" *.sql /Z /FFT /R:3 /W:5 /XO /V /TS /FP
```

### 5. Return Code Validation

| Code | Result  |
| ---- | ------- |
| 0-3  | Success |
| >=4  | Error   |

### 6. Move Processed Files

```bat
robocopy "%ORIGEM%" "%PROCESSADOS%" *.sql /MOV
```

---

## Logging

Logs:

```text
C:\Backup_mysql_portal\logs
```

Execution Tracking:

```text
C:\Backup_mysql_portal\scripts\execucao.txt
```

Errors:

```text
C:\Backup_mysql_portal\erros
```

---

## Task Scheduler

### Recommended Trigger

* At workstation unlock

### Settings

* Run only when user is logged on
* Run with highest privileges
* Delay task for 30 seconds

### Action

Program:

```text
cmd.exe
```

Arguments:

```text
/c "C:\Backup_mysql_portal\scripts\backup_onedrive.bat"
```

---

## OneDrive Considerations

Important behavior:

* Files are copied locally first
* Cloud synchronization is asynchronous
* Delays may occur before files appear online

### Success Indicators

* Backup file exists locally
* Robocopy returns code 0–3
* OneDrive synchronization notification appears

---

## Known Issues

| Problem                        | Cause                        |
| ------------------------------ | ---------------------------- |
| Task does not start at logon   | Task Scheduler timing        |
| OneDrive folder appears empty  | Synchronization delay        |
| Robocopy reports "extra files" | File already exists          |
| Encoding issues                | CMD not configured for UTF-8 |
| Drive Z: unavailable           | SMB share not ready          |

---

## Future Improvements

* Backup validation using MD5/SHA256
* Automatic synchronization retry
* Email or Teams notifications
* Windows Service execution
* Automatic ZIP compression
* Backup retention policies

---

## Conclusion

This project demonstrates a complete cross-platform backup workflow integrating:

* Linux automation with Bash
* MySQL backup generation
* Docker container interaction
* SMB/Samba file sharing
* Windows Batch automation
* OneDrive synchronization
* Logging and monitoring

The solution was designed to automate backup generation, file transfer and cloud synchronization while maintaining a simple and reliable workflow.
