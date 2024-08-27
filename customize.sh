# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010
SKIPUNZIP=1
LOG=$NVBASE/fogimp.log

exec 3>&1 1>>$LOG 2>&1
exec 1>&3
set -x
echo "
⟩ $(date -Is)" >>$LOG
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2

. $MODPATH/boot_config.sh

set_permissions() {
	set_perm_recursive "$MODPATH" 0 0 0755 0644
	set_perm_recursive "$MODPATH/boot_config.sh" 0 2000 0755 0755
	set_perm_recursive "$MODPATH/system/bin" 0 2000 0755 0755
}

main() {
	uprint "⟩ Applying props"

	lmkd_props_clean
	cat <<EOF >$MODPATH/system.prop
persist.sys.miui.camera.boost.opt=false
ro.lmk.kill_heaviest_task=true
EOF

	if grep -q file /proc/swaps; then
		cat <<EOF >>$MODPATH/system.prop
persist.device_config.lmkd_native.thrashing_limit_critical=150
ro.lmk.swap_util_max=60
EOF
	else
		cat <<EOF >>$MODPATH/system.prop
ro.lmk.swap_util_max=100
EOF
	fi

	approps $MODPATH/system.prop

	relmkd
	uprint "⟩ lmkd reinitialized
	"
}

set_permissions
main
