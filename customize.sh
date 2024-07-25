# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010
SKIPUNZIP=1
LOG=$NVBASE/fogimp.log

exec 3>&1 1>>$LOG 2>&1
exec 1>&3
set -x
echo "
⟩ $(date -Is)" >>$LOG

. $MODPATH/boot_config.sh

set_permissions() {
	unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2
	set_perm_recursive "$MODPATH" 0 0 0755 0644
	set_perm_recursive "$MODPATH/boot_config.sh" 0 2000 0755 0755
	set_perm_recursive "$MODPATH/system/bin" 0 2000 0755 0755
}

# ktweak is insignificant in this tweak
# because swap will make a high io anyway so it
# meaningless to try to make your device smoother
remove_ktweak_module() {
	[ -d $NVBASE/modules/ktweak ] || [ -d $NVBASE/modules_update/ktweak ] && {
		uprint "  › Removing Ktweak module"
		krmcode=0
		touch $NVBASE/modules/ktweak/remove && krmcode=$((krmcode + 1))
		$BIN/rm -rf $NVBASE/modules_update/ktweak && krmcode=$((krmcode + 1))
		[ $krmcode -gt 0 ] && uprint "  » Ktweak module is removed. Reboot after installation is finished.
"
	}
}

main() {
	uprint "
⟩ Applying props"

	# If swap exist use this props instead
	if grep file -q /proc/swaps; then
		cat <<EOF >$MODPATH/system.prop
ro.lmk.thrashing_limit_decay=80
ro.lmk.upgrade_pressure=40
ro.lmk.downgrade_pressure=50
ro.lmk.psi_partial_stall_ms=40
ro.lmk.psi_complete_stall_ms=500
ro.lmk.swap_free_low_percentage=5
persist.device_config.lmkd_native.thrashing_limit_critical=60
persist.sys.miui.camera.boost.opt=false
ro.config.low_ram.support_miuilite_plus=false
EOF

		approps $MODPATH/system.prop
		remove_ktweak_module
	else
		cat <<EOF >$MODPATH/system.prop
ro.lmk.thrashing_limit_decay=80
ro.lmk.upgrade_pressure=50
ro.lmk.downgrade_pressure=60
persist.device_config.lmkd_native.thrashing_limit_critical=60
persist.sys.miui.camera.boost.opt=false
ro.config.low_ram.support_miuilite_plus=false
EOF

		approps $MODPATH/system.prop
	fi

	relmkd
	uprint "⟩ lmkd reinitialized"
}

set_permissions
main
