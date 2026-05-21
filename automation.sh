#!/bin/bash
#================================================
#   PROJECT: DevOps Server Automation
#   Author : Junior DevOps Engineer
#   GitHub : github.com/tumhara-username
#================================================

#------------------------------------------
# COLORS — output colorful karo
#------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#------------------------------------------
# VARIABLES
#------------------------------------------
SERVER="production-server-01"
BACKUP_DIR="/home/ubuntu/backups"
LOG_FILE="/home/ubuntu/automation.log"
DISK_LIMIT=80
FILES="file1.txt file2.txt file3.txt"
USERS="ahmed sara ali"

#------------------------------------------
# FUNCTION 1 — Log likhna
#------------------------------------------
write_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

#------------------------------------------
# FUNCTION 2 — Service Check
#------------------------------------------
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✅ $1 is running${NC}"
        write_log "SUCCESS: $1 is running"
    else
        echo -e "${RED}❌ $1 is not running${NC}"
        write_log "ERROR: $1 is not running"
    fi
}

#------------------------------------------
# FUNCTION 3 — Disk Check
#------------------------------------------
check_disk() {
    USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ $USAGE -gt $DISK_LIMIT ]; then
        echo -e "${RED}⚠️  WARNING: Disk ${USAGE}% full!${NC}"
        write_log "WARNING: Disk usage is ${USAGE}%"
    else
        echo -e "${GREEN}✅ Disk OK: ${USAGE}%${NC}"
        write_log "OK: Disk usage is ${USAGE}%"
    fi
}

#------------------------------------------
# FUNCTION 4 — User Create karna
#------------------------------------------
create_user() {
    if id "$1" &>/dev/null; then
        echo -e "${YELLOW}⚠️  User $1 already exists!${NC}"
    else
        sudo useradd -m $1
        echo "$1:Pass@123" | sudo chpasswd
        echo -e "${GREEN}✅ User $1 created!${NC}"
        write_log "SUCCESS: User $1 created"
    fi
}

#------------------------------------------
# MAIN PROGRAM SHURU
#------------------------------------------
clear
echo "========================================="
echo "   TechCloud DevOps Automation v1.0     "
echo "========================================="
echo ""

# --- TASK 1: FOR LOOP — File Backup ---
echo -e "${YELLOW}--- TASK 1: File Backup ---${NC}"
mkdir -p $BACKUP_DIR
for FILE in $FILES
do
    if [ -f $FILE ]; then
        cp $FILE $BACKUP_DIR
        echo -e "${GREEN}✅ $FILE backed up!${NC}"
        write_log "BACKUP: $FILE copied to $BACKUP_DIR"
    else
        echo -e "${RED}❌ $FILE not found!${NC}"
        write_log "ERROR: $FILE not found"
    fi
done
echo ""

# --- TASK 2: FOR LOOP — Users Banana ---
echo -e "${YELLOW}--- TASK 2: User Creation ---${NC}"
for USER in $USERS
do
    create_user $USER
done
echo ""

# --- TASK 3: IF/ELSE — Disk Check ---
echo -e "${YELLOW}--- TASK 3: Disk Check ---${NC}"
check_disk
echo ""

# --- TASK 4: SERVICE CHECK ---
echo -e "${YELLOW}--- TASK 4: Service Status ---${NC}"
check_service ssh
check_service apache2
check_service docker
echo ""

# --- TASK 5: UNTIL LOOP — Apache Wait ---
echo -e "${YELLOW}--- TASK 5: Apache2 Check ---${NC}"
count=0
until systemctl is-active --quiet apache2
do
    echo "⏳ Waiting for Apache2..."
    sleep 2
    count=$((count + 1))
    if [ $count -gt 3 ]; then
        echo -e "${RED}❌ Apache2 failed to start!${NC}"
        write_log "ERROR: Apache2 failed to start"
        break
    fi
done

# --- FINAL REPORT ---
echo ""
echo "========================================="
echo "         AUTOMATION COMPLETE! ✅         "
echo "========================================="
echo ""
echo "📋 Log file saved at: $LOG_FILE"
echo "📁 Backups saved at:  $BACKUP_DIR"
echo ""
cat $LOG_FILE
