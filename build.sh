#!/bin/bash
set -e # Exit on error

TAG="beta"
INSTALL=false                                  # Default: No installation

# Root Check Function
check_root() {
	local message="$1"

	if su -c "echo" >/dev/null 2>&1; then
		return 1 # Not root
	elif [ "$EUID" -ne 0 ]; then
		echo "$message"
		exit 1
	fi
}

# Validate Arguments
validate_args() {
	for arg in "$@"; do
		if [[ ! "$arg" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
			echo "> Error: Arguments must be numeric"
			exit 1
		fi
	done
}

# Read version from module.prop
read_version_info() {
	grep -Eo 'version=v[0-9.]+' module.prop | cut -d'=' -f2 | sed 's/v//'
}

# Read versionCode from module.prop
read_version_code() {
	grep -Eo 'versionCode=[0-9]+' module.prop | cut -d'=' -f2
}

# Generate Changelog from Git and remove old ones
generate_changelog() {
	local version="$1"
	local versionCode="$2"
	local changelog_file="fmiop-v${version}_${versionCode}-changelog.md"
	local message="
📣 For more updates and discussions about bugs, features, etc.,
join our ⌯⌲ Telegram channel: [**Initechzer0**](https://t.me/initentangtech)
or our ⌯⌲ Telegram group: [**Initechzer0 Chat**](https://t.me/+ff5HBVsV8gsxODk1)."

	# Remove previous changelogs
	rm -f fmiop-v*-changelog.md
	echo "- Removed old changelogs"

	echo "# Changelog for v${version} (Build ${versionCode})" >"$changelog_file"
	echo "$message" >>"$changelog_file"
	echo "" >>"$changelog_file"

	# Include only local commits not pushed to remote
	local local_commits
	local_commits=$(git log @{u}..HEAD --pretty=format:"- %s (%h)" 2>/dev/null)

	if [[ -n "$local_commits" ]]; then
		echo "$local_commits" >>"$changelog_file"
	else
		echo "- No local changes to include in changelog" >>"$changelog_file"
	fi

	echo "" >>"$changelog_file"
	echo "- Auto-generated from local Git commits" >>"$changelog_file"

	echo "- Changelog generated: $changelog_file"
}

# Parse arguments
while getopts ":i" opt; do
	case "$opt" in
	i) INSTALL=true ;; # Enable installation
	*)
		echo "Usage: $0 [-i] <version> <versionCode>"
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

# Main Execution
main() {
	local version="${1:-$(read_version_info)}"
	local versionCode="${2:-$(($(read_version_code) + 1))}"

	validate_args "$version" "$versionCode"

	# Update module.prop
	sed -i -E "s/^version=v[0-9.]+/version=v$version/; s/^versionCode=[0-9]+/versionCode=$versionCode/" module.prop

	local module_name
	module_name=$(grep -Eo '^id=.*' module.prop | cut -d'=' -f2)
	
	# Generate Changelog
	generate_changelog "$version" "$versionCode"

	local package_name="packages/${module_name}-v${version}_${versionCode}-$TAG.zip"

	# 🧹 Delete old packages for this module
	echo "- Cleaning up old packages..."
	find packages/ -type f -name "${module_name}-v*.zip" ! -name "$(basename "$package_name")" -delete

	echo "- Creating zip package: $package_name"
	7za a -mx=9 -bd -y "$package_name" \
		META-INF \
		boot_config.sh \
		customize.sh \
		module.prop \
		service.sh >/dev/null 2>&1

	if $INSTALL; then
		check_root "You need ROOT to install this module" || su -c "magisk --install-module $package_name"
	else
		echo "- Skipping installation. Package built at: $package_name"
	fi
	
	adb push "$package_name" /sdcard/Download
}

# Run the script
main "$@"
