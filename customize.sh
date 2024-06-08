# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010
SKIPUNZIP=1
# exec 3>&1 2>&1
# set -x

unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/boot_config.sh" 0 2000 0755 0755

uprint() {
	if [ "$1" = "n" ]; then
		ui_print ""
		ui_print "  $2"
	else
		ui_print "  $1"
	fi
}

. $MODPATH/boot_config.sh

approps $MODPATH/system.prop
relmkd
