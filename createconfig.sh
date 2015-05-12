#!/bin/bash
# Quick config creating script.
# Given a number of configs on stdin, completes the config by finding default values for
# those cvars from 'default_cvars' (taken from
# https://developer.valvesoftware.com/wiki/List_of_TF2_console_commands_and_variables) so
# that there's no ugly leftover options from one config poluting the use of the other.

allcvars=$(cat $@|sed 's/ .*//g'|sort|uniq)

for file in $@; do
	echo "$file config:"
	GENCONFIG=""
	for cvar in $allcvars; do
		# See if an option exists already
		CFGSPECIFIC=$(grep -i "$cvar " $file)
		if [ ! -z "$CFGSPECIFIC" ]; then
			# We're good, use the config version
			GENCONFIG+="$CFGSPECIFIC\n"
		else
			# We need to get the default version
			CFGDEFAULT=$(grep -i "$cvar " default_cvars)
			if [ -z "$CFGDEFAULT" ]; then
				>&2 echo "    Warning: $cvar not found in default options!"
			else
				GENCONFIG+="$CFGDEFAULT\n"
			fi
		fi
	done
	CONFIG="$(echo -e $GENCONFIG)"
	LINES=$(echo "$CONFIG"| paste - - - - - -d"\;")
	(
		IFS=$'\n'
		LINEARR=( $LINES )
		echo "alias config_${file} \"${LINEARR[0]}; config_${file}_1\""
		for i in $(seq 1 $(( ${#LINEARR[@]} - 1)) ); do
			if [ $i -eq $(( ${#LINEARR[@]} - 1)) ]; then
				echo "alias config_${file}_${i} \"${LINEARR[$i]}; echo ${file} config loaded.\""
			else
				echo "alias config_${file}_${i} \"${LINEARR[$i]}; config_${file}_$(( $i + 1))\""
			fi
		done
	)
done
