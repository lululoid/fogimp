# shellcheck disable=SC3010,SC3060,SC3043,SC2086,SC2046
MODDIR=${0%/*}
NVBASE=/data/adb
# shellcheck disable=SC2034
BIN=/system/bin

exec 3>&1 1>>"$NVBASE/fogimp.log" 2>&1
set -x # Prints commands, prefixing them with a character stored in an environmental variable ($PS4)

until [ $(resetprop sys.boot_completed) -eq 1 ] &&
	[ -d /sdcard ]; do
	sleep 5
done

if [ -d /data/adb/modules/ktweak ]; then
	sleep 1m
fi

. $MODDIR/boot_config.sh
