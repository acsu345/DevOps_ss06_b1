#!/bin/bash
# ==============================================================================
# Script: setup.sh
# Mo ta: Khoi tao va phan quyen nang cao cho thu muc ung dung web theo FHS
# Duong dan: /var/www/my-app
# ==============================================================================

set -e

# Clear log colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== [BUOC 1] KHOI TAO CAU TRUC THU MUC FHS ===${NC}"
sudo mkdir -p /var/www/my-app/public
sudo mkdir -p /var/www/my-app/logs
echo "[OK] Da tao /var/www/my-app/public va /var/www/my-app/logs"

echo -e "\n${BLUE}=== [BUOC 2] THAY DOI CHU SO HUU VA NHOM SO HUU ===${NC}"
# Dam bao group www-data ton tai
if ! getent group www-data > /dev/null 2>&1; then
    sudo groupadd www-data
fi

# Gan owner cho user hien tai va group owner la www-data
CURRENT_USER=${SUDO_USER:-$USER}
sudo chown -R ${CURRENT_USER}:www-data /var/www/my-app
echo "[OK] Da thiet lap Owner: ${CURRENT_USER}, Group: www-data cho /var/www/my-app"

echo -e "\n${BLUE}=== [BUOC 3] PHAN QUYEN CHIT TIET (CHMOD) ===${NC}"
# Public: Owner (rwx=7), Group (r-x=5), Others (---=0) -> 750 (drwxr-x---)
sudo chmod 750 /var/www/my-app/public
echo "[OK] Da gan quyen 750 (drwxr-x---) cho /var/www/my-app/public"

# Logs: Owner (rwx=7), Group (rwx=7), Others (---=0) -> 770 (drwxrwx---)
sudo chmod 770 /var/www/my-app/logs
echo "[OK] Da gan quyen 770 (drwxrwx---) cho /var/www/my-app/logs"

echo -e "\n${BLUE}=== [BUOC 4] KIEM TRA DAU RA LS -LA ===${NC}"
ls -la /var/www/my-app

echo -e "\n${GREEN}=== HOAN THANH KHOI TAO VA PHAN QUYEN ACCURACY! ===${NC}"
