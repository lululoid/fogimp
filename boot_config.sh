# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010,SC2046
alias uprint="ui_print || echo"

setval() {
	value=$1
	file=$2

	echo $value >$file && {
		cat <<EOF
  › $file 
EOF
		uprint "  » $(cat $file)"
	}
}

rm_prop() {
	for prop in "$@"; do
		resetprop -d $prop && cat <<EOF

X $prop deleted
EOF
	done
}

approps() {
	prop_file=$1

	set -f
	grep -v '^ *#' "$prop_file" |
		while IFS='=' read -r prop value; do
			resetprop -n -p $prop $value
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
rm_prop persist.sys.mms.bg_apps_limit

until [ $(resetprop sys.boot_completed) -eq 1 ] &&
	[ -d /sdcard ]; do
	sleep 5
done

if [ -d /data/adb/modules/ktweak ]; then
	sleep 1m
fi

setval none /sys/block/mmcblk0/queue/scheduler
setval 2048 /sys/devices/virtual/bdi/179:0/read_ahead_kb
setval 120 /proc/sys/vm/swappiness
