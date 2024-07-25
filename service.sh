# shellcheck disable=SC3010,SC3060,SC3043,SC2086,SC2046
MODDIR=${0%/*}
NVBASE=/data/adb
# shellcheck disable=SC2034
BIN=/system/bin
LOG=$NVBASE/fogimp.log

exec 3>&1 1>>$LOG 2>&1
set -x # Prints commands, prefixing them with a character stored in an environmental variable ($PS4)
echo "
⟩ $(date -Is)" >>$LOG

. $MODDIR/boot_config.sh
