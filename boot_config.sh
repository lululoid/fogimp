# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010,SC2046
alias uprint="echo"
alias resetprop="resetprop -v"

setval() {
	value=$1
	file=$2

	echo $value >$file && {
		cat <<EOF
  › $file 
EOF
		uprint "  » $(cat $file)
		"
	}
}

rm_prop() {
	for prop in "$@"; do
		resetprop -d $prop && cat <<EOF
  × $prop deleted

EOF
	done
}

lmkd_props_clean() {
	set --
	set \
		"ro.lmk.low" \
		"ro.lmk.medium" \
		"ro.lmk.critical" \
		"ro.lmk.critical_upgrade" \
		"ro.lmk.kill_heaviest_task" \
		"ro.lmk.kill_timeout_ms" \
		"ro.lmk.psi_partial_stall_ms" \
		"ro.lmk.psi_complete_stall_ms" \
		"ro.lmk.thrashing_limit_decay" \
		"ro.lmk.swap_util_max" \
		"sys.lmk.minfree_levels" \
		"ro.lmk.upgrade_pressure" \
		"ro.lmk.downgrade_pressure" \
		"persist.device_config.lmkd_native.thrashing_limit_critical" \
		"ro.lmk.swap_free_low_percentage"
	rm_prop "$@"
}

approps() {
	prop_file=$1

	set -f
	resetprop -f $prop_file
	grep -v '^ *#' "$prop_file" |
		while IFS='=' read -r prop value; do
			cat <<EOF
  › $prop 
EOF
			{
				[ "$(getprop $prop)" == ${value//=/ } ] &&
					uprint "  » $value
"
			} || uprint "  ! Failed
"
		done
}

relmkd() {
	resetprop lmkd.reinit 1
}

uprint "⟩ Applying tweaks"
# experimental, no bad effects so far
# rm_prop persist.sys.mms.bg_apps_limit

until [ $(resetprop sys.boot_completed) -eq 1 ] &&
	[ -d /sdcard ]; do
	sleep 5
done

sdcard_scheduler_file=/sys/block/mmcblk0/queue/scheduler
avail_scheds="$(cat "$sdcard_scheduler_file")"
for sched in cfq noop kyber bfq mq-deadline none; do
	if [[ "$avail_scheds" == *"$sched"* ]]; then
		setval $sched $sdcard_scheduler_file
		break
	fi
done
setval 1024 /sys/devices/virtual/bdi/179:0/read_ahead_kb
[ ! -d /data/adb/modules/fmiop ] && setval 100 /proc/sys/vm/swappiness
