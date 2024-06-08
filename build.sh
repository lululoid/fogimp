#!/bin/bash

version=$1
versionCode=$2

# Check for decimal in arguments
for arg in "$@"; do
	if [[ $arg =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
		true
	else
		echo "> Arguments must be number"
		exit 1
	fi
done

last_version=$(grep -o 'version=v[0-9.]*' module.prop | cut -d'=' -f2 | sed 's/v//')

if [ -z "$version" ]; then
	version=$(grep -o 'version=v[0-9.]*' module.prop | cut -d'=' -f2 | sed 's/v//')
fi

if [ -z "$versionCode" ]; then
	versionCode=$(grep versionCode module.prop | cut -d "=" -f2)
	versionCode=$((versionCode + 1))
	if [ "$(echo "$version > $last_version" | bc -l)" -eq 1 ]; then
		first_two=$(echo "$versionCode" | sed -E 's/^([0-9]{2}).*/\1/')
		first_two=$((first_two + 1))
		versionCode=$(echo "$versionCode" | sed -E "s/[0-9]{2}(.*)/$first_two\1/")
	fi
fi

# U think I lazy to type? No, i just really forgetful sometimes
sed -i "s/version=v[0-9.]*-beta/version=v$version-beta/g; s/versionCode=[0-9]*/versionCode=$versionCode/g" module.prop

module_name=$(sed -n 's/id=\(.*\)/\1/p' module.prop)
7za a "packages/$module_name-v${version}_$versionCode-beta.zip" META-INF \
	boot_config.sh \
	build.sh \
	customize.sh \
	module.prop \
	service.sh \
	system.prop
