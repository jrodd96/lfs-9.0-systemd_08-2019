#!/bin/bash

# Converts the results of 'head -n7 /proc/cpuinfo' into the correlating Intel microcode
# identification string for copying to the firmware directory

# NOTE: Ensure that this script is copied to the same directory as the extracted
# intel-ucode source directory before running to ensure proper transport of the
# microcode firmware

main() {

	head -n7 /proc/cpuinfo;

	hexa

}

hexa() {

	echo
	echo "Use the output of the above command to answer the following:"
	echo
	read -p "   Enter the value for cpu family: " cpu
	read -p "   Enter the value for model: " model
	read -p "   Enter the value for stepping: " stepping

	# For Dell Inspiron 5579:
	#  cpu family : 6     = 06 (hexa)
	#  model      : 142   = 8e (hexa)
	#  stepping   : 10    = 0a (hexa)

	# hexadecimal conversion:

	# adds a 0 before cpu no. if < 16 for proper ident name (15 = f, 16 = 10)
	if [ "$cpu" -lt "16" ]; then
		hex_cpu="0$(printf '%x\n' $cpu)"
	else
		hex_cpu=$(printf '%x\n' $cpu)
	fi

	hex_mod=$(printf '%x\n' $model)
	# Unlikely that the model no. will ever be < 10 to need '0x'

	# adds a 0 before stepping no. if > 10 for proper ident name
	if [ "$stepping" -gt "9" ]; then
		hex_step="0$(printf '%x\n' $stepping)"
	else
		hex_step=$(printf '%x\n' $stepping)
	fi

	ident="$hex_cpu-$hex_mod-$hex_step"
	# Dell Inspiron 5579 = 06-8e-0a

	echo
	echo "Your PC's Intel microcode identifier is: $ident"

	read -p "Is this correct? (y/n): " answer

	if [ "$answer" == "y" ]; then
		firm
		exit 0
	else
		exit 1
	fi
}

firm() {

	echo
	echo "Creating firmware directory..."
	mkdir -pv /lib/firmware/intel-ucode;
	echo "Locating and copying firmware files..."
	cp -v intel-ucode/intel-ucode/$ident /lib/firmware/intel-ucode;
	echo "Done."
}

main
