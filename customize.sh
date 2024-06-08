# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010
exec 3>&1 2>&1
set -x
SKIPUNZIP=1

. $MODPATH/boot_config

approps $MODPATH/system.prop
relmkd
