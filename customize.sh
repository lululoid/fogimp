# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010
SKIPUNZIP=1
# exec 3>&1 2>&1
# set -x

unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/boot_config.sh" 0 2000 0755 0755
set_perm_recursive "$MODPATH/system/bin" 0 2000 0755 0755

. $MODPATH/boot_config.sh

uprint "
⟩ Applying props"

# If swap exist use this props instead
if grep file -q /proc/swaps; then
	cat <<EOF >$MODPATH/system.prop
ro.lmk.thrashing_limit_decay=80
ro.lmk.upgrade_pressure=45
ro.lmk.downgrade_pressure=50
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_util_max=60
persist.device_config.lmkd_native.thrashing_limit_critical=60
persist.sys.miui.camera.boost.opt=false
ro.config.low_ram.support_miuilite_plus=false
EOF
else
	cat <<EOF >$MODPATH/system.prop
ro.lmk.thrashing_limit_decay=80
ro.lmk.upgrade_pressure=50
ro.lmk.downgrade_pressure=60
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_util_max=60
persist.device_config.lmkd_native.thrashing_limit_critical=60
persist.sys.miui.camera.boost.opt=false
ro.config.low_ram.support_miuilite_plus=false
EOF
fi

approps $MODPATH/system.prop
relmkd
uprint "⟩ lmkd reinitialized"
