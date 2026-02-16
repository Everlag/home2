# Restic Backup System

This directory contains the Salt-managed restic backup system configuration.

## Overview

- **Bucket**: `restic-vms` (Google Cloud Storage)
- **Schedule**: Weekly backups every Sunday at 1 PM EST
- **Config Directory**: `/etc/restic/`

## Files

- `/etc/restic/restic-repos` - List of directories to backup (one per line)
- `/etc/restic/restic-backup.sh` - Backup script (contains secrets, mode 700)
- `/etc/restic/gcp-service-account.json` - GCP service account credentials (mode 600)

## How to Prepare a New Repository

### 1. Set Environment Variables

You can grab this out of /etc/restic/restic-backup.sh

```bash
export GOOGLE_PROJECT_ID="1076325401812"
export GOOGLE_APPLICATION_CREDENTIALS="/etc/restic/gcp-service-account.json"
export RESTIC_PASSWORD="your-restic-password"
```

### 2. Choose Directory to Backup

Determine the full path of the directory you want to backup. For example:

- `/etc/bass_transcode_1720221226`

### 3. Determine Repository Name

The repository name is the **basename** (last component) of the path:

- `/etc/bass_transcode_1720221226` → repo name: `bass_transcode_1720221226`

### 4. Initialize the Repository

```bash
restic -r gs:restic-vms:<repo-name> init
```

**Example:**
```bash
# For /var/lib/docker:
restic -r gs:restic-vms:docker init

# For /etc/bass_transcode_1720221226:
restic -r gs:restic-vms:bass_transcode_1720221226 init
```

### 5. Add Directory to Backup List

```bash
echo "/path/to/directory" | sudo tee -a /etc/restic/restic-repos
```

**Example:**
```bash
echo "/var/lib/docker" | sudo tee -a /etc/restic/restic-repos
```

### 6. Test Manual Backup

Trigger a backup manually to verify everything works:

```bash
sudo systemctl start restic-backup.service
```

### 7. Check Backup Logs

```bash
# View recent logs
journalctl -u restic-backup.service -n 50

# Follow logs in real-time
journalctl -u restic-backup.service -f
```

## Management Commands

### Check Timer Status
```bash
systemctl status restic-backup.timer
```

### List All Scheduled Timers
```bash
systemctl list-timers
```

### Manually Trigger Backup
```bash
sudo systemctl start restic-backup.service
```

### View Backup History
```bash
# Set credentials first
export GOOGLE_PROJECT_ID="1076325401812"
export GOOGLE_APPLICATION_CREDENTIALS="/etc/restic/gcp-service-account.json"
export RESTIC_PASSWORD="your-restic-password"

# List snapshots for a specific repo
restic -r gs:restic-vms:<repo-name> snapshots
```

### Restore from Backup
```bash
# Set credentials first
export GOOGLE_PROJECT_ID="1076325401812"
export GOOGLE_APPLICATION_CREDENTIALS="/etc/restic/gcp-service-account.json"
export RESTIC_PASSWORD="your-restic-password"

# List snapshots
restic -r gs:restic-vms:<repo-name> snapshots

# Restore latest snapshot to a directory
restic -r gs:restic-vms:<repo-name> restore latest --target /path/to/restore
```

## Troubleshooting

### Check if directory is in backup list
```bash
cat /etc/restic/restic-repos
```

### Verify credentials are set
The backup script automatically sets credentials from the pillar, but you can verify manually:
```bash
sudo cat /etc/restic/restic-backup.sh | grep "export GOOGLE"
```

### Check GCS bucket access
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/etc/restic/gcp-service-account.json"
gsutil ls gs://restic-vms/
```

## Security Notes

- All files in `/etc/restic/` are root-only (mode 700/600)
- The backup script contains sensitive credentials
- Service account JSON contains GCP credentials
- Never commit these files to version control
- Credentials are managed via Salt pillar

## Weekly Schedule

The timer runs every **Sunday at 1:00 PM EST**.

To check next scheduled run:
```bash
systemctl list-timers restic-backup.timer
```
