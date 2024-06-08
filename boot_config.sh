# shellcheck disable=SC3043,SC2034,SC2086,SC3060,SC3010,SC2046
setval() {
	value=$1
	file=$2

	echo $value >$file
	uprint_n $file || echo $file
	echo "  $(cat $file)" || uprint "  $(cat $file)"
}

approps() {
	prop_file=$1

	set -f
	grep -v '^ *#' "$prop_file" |
		while IFS='=' read -r prop value; do
			resetprop -n -p $prop $value
			uprint_n "$prop"
			{
				[ "$(getprop $prop)" == ${value//=/ } ] &&
					uprint $value
			} || uprint "! Failed"
		done
}

relmkd() {
	resetprop lmkd.reinit 1
}

while [ $(resetprop sys.boot_completed) -ne 1 ]; do
	sleep 1
done

setval none /sys/block/mmcblk0/queue/scheduler
# setval 2048 /sys/devices/virtual/bdi/179:0/read_ahead_kb
setval 100 /proc/sys/vm/swappiness
