
# Backup Lab — Automated Incremental Backups with rsync and cron

A hands-on lab where I built a fully automated backup system using rsync and cron on two Linux virtual machines. Backups are sent over an encrypted VPN tunnel, scheduled daily, logged for auditing, and tested with a full data loss simulation and restore.

---

## Lab Environment

| Role | OS | VPN IP |
|---|---|---|
| Backup Source | Ubuntu 24.04 | 10.8.0.1 |
| Backup Destination | Kali Linux | 10.8.0.6 |

**Note:** Backup traffic runs over an OpenVPN tunnel — see [openvpn-lab](https://github.com/IQ/openvpn-lab) for VPN setup.

---

## What I Built

- A **source directory** on Ubuntu simulating critical server data
- A **backup destination** on Kali simulating a remote backup server
- **Manual rsync backup** to verify transfer works correctly
- **Incremental sync** — rsync only transfers changed files, not everything
- **Automated daily backups** using cron scheduled at 2:00 AM
- **Backup logging** to audit every backup run
- **Full restore test** — deleted a file and recovered it from backup

---

## Network Diagram

```
+-------------------+       rsync over VPN tunnel        +-------------------+
|   Ubuntu 24.04    |  -------------------------------->  |    Kali Linux     |
|   Backup Source   |     Encrypted - AES-256-GCM         |  Backup Storage   |
|    10.8.0.1       |                                     |    10.8.0.6       |
| ~/important-data/ |                                     |    ~/backups/     |
+-------------------+                                     +-------------------+
```

---

## Steps Taken

### 1. Created Source Data on Ubuntu
```bash
mkdir ~/important-data
echo "This is a critical file" > ~/important-data/file1.txt
echo "Database config backup" > ~/important-data/file2.txt
echo "Server logs" > ~/important-data/file3.txt
```

### 2. Created Backup Destination on Kali
```bash
mkdir ~/backups
```

### 3. Ran Manual rsync Backup
```bash
rsync -avz ~/important-data/ IQ@10.8.0.6:~/backups/
```

**Flags explained:**
- `-a` — archive mode, preserves permissions, timestamps, and ownership
- `-v` — verbose output, shows every file being transferred
- `-z` — compresses data during transfer to save bandwidth

**Result:** All three files transferred successfully over the VPN tunnel.

### 4. Tested Incremental Sync
```bash
echo "New critical config" > ~/important-data/file4.txt
rsync -avz ~/important-data/ IQ@10.8.0.6:~/backups/
```

**Result:** Only `file4.txt` was transferred — rsync skipped the unchanged files. This is what makes rsync efficient in production environments.

### 5. Automated Backups with cron
```bash
crontab -e
```

Added this cron job:
```
0 2 * * * rsync -avz /home/vboxuser/important-data/ IQ@10.8.0.6:~/backups/ >> /home/vboxuser/backup.log 2>&1
```

**What this does:**
- Runs every day at 2:00 AM automatically
- Logs every backup run to `backup.log` including errors
- No manual intervention required

### 6. Simulated Data Loss and Restored from Backup
```bash
# Simulate data loss
rm ~/important-data/file2.txt

# Verify file is gone
ls ~/important-data/

# Restore from backup
rsync -avz IQ@10.8.0.6:~/backups/file2.txt ~/important-data/

# Verify restore
ls ~/important-data/
```

**Result:** File successfully recovered from backup on Kali.

---

## Cron Schedule Reference

| Field | Value | Meaning |
|---|---|---|
| Minute | 0 | At minute 0 |
| Hour | 2 | At 2 AM |
| Day of month | * | Every day |
| Month | * | Every month |
| Day of week | * | Every day of week |

---

## Problems I Hit and How I Fixed Them

| Problem | Cause | Fix |
|---|---|---|
| VPN tunnel dropped mid-lab | VMs restarted, Host-Only IP lost on Kali | Reassigned IP with `sudo ip addr add`, restarted OpenVPN server, reconnected client |
| rsync couldn't reach Kali | VPN tunnel was down | Restored VPN connection first, verified ping through tunnel before retrying |
| tun interface changed to tun2 | Previous tun0 session left a stale route | Harmless — used `ip a show tun2` to confirm new interface, worked normally |

---

## Key Concepts Learned

- **rsync** — incremental file sync tool that only transfers changed data, used widely in production backup systems
- **Incremental backup** — only backing up what changed since last run, saving time and bandwidth
- **cron** — Linux task scheduler for automating recurring jobs
- **Backup logging** — capturing backup run output to a log file for auditing and troubleshooting
- **Restore testing** — a backup is only useful if you can restore from it; always test recovery
- **Backup over VPN** — encrypting backup traffic in transit to protect sensitive data

---

## Full Backup Cycle Proven

| Stage | Status |
|---|---|
| Manual backup | ✅ |
| Incremental sync | ✅ |
| Automated scheduling | ✅ |
| Backup logging | ✅ |
| Data loss simulation | ✅ |
| Successful restore | ✅ |

---

## Tools Used

- rsync
- cron
- OpenVPN (for encrypted transfer)
- Ubuntu 24.04
- Kali Linux
