# This Script help you turn on and off 4 LEDs over BeagleBone Blue.
# The work is done thanks to MR. Nasser Afshin and I just customize this for Beagle Bone 


#!/bin/sh
DEVMEM="/sbin/devmem"

GPIO1=0x4804C000
GPIO1_OE_ADDR=$((GPIO1+0x134))   	#Output enable register
GPIO1_CLEARDATAOUT=$((GPIO1+0x190))  	#Clear data out register
GPIO1_SETDATAOUT=$((GPIO1+0x194))   	#Set data out register

LED0_VAL=0x00200000
LED1_VAL=0x00400000
LED2_VAL=0x00800000
LED3_VAL=0x01000000

LED0_OE_VAL=$(printf "0x%8x" $((~LED0_VAL & 0xFFFFFFFF)) ) #0xFFDFFFFF
LED1_OE_VAL=$(printf "0x%8x" $((~LED1_VAL & 0xFFFFFFFF)) ) #0xFFBFFFFF
LED2_OE_VAL=$(printf "0x%8x" $((~LED2_VAL & 0xFFFFFFFF)) ) #0xFF7FFFFF
LED3_OE_VAL=$(printf "0x%8x" $((~LED3_VAL & 0xFFFFFFFF)) ) #0xFEFFFFFF



print_help () {
	echo "Usage: $0 <LED0 | LED1 | LED2 | LED3> <ON | OFF>"
}

if [ -z "$1" ]
then
	print_help
	exit 1
fi

case $1 in
	LED0)
		echo "Setting GPIO $1 to $2 ..."
		$DEVMEM $GPIO1_OE_ADDR 32 $LED0_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO1_SETDATAOUT 32 $LED0_VAL
				;;
			OFF)
				$DEVMEM $GPIO1_CLEARDATAOUT 32 $LED0_VAL
				;;
			*)
				print_help
				exit 1
				;; 
		esac
		;;
	LED1)
		echo "Setting GPIO $1 to $2 ..."
		$DEVMEM $GPIO1_OE_ADDR 32 $LED1_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO1_SETDATAOUT 32 $LED1_VAL
				;;
			OFF)
				$DEVMEM $GPIO1_CLEARDATAOUT 32 $LED1_VAL
				;;
			*)
				print_help
				exit 1
				;; 
		esac
		;;
	LED2)
		echo "Setting GPIO $1 to $2 ..."
		$DEVMEM $GPIO1_OE_ADDR 32 $LED2_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO1_SETDATAOUT 32 $LED2_VAL
				;;
			OFF)
				$DEVMEM $GPIO1_CLEARDATAOUT 32 $LED2_VAL
				;;
			*)
				print_help
				exit 1
				;; 
		esac
		;;
	LED3)
		echo "Setting GPIO $1 to $2 ..."
		$DEVMEM $GPIO1_OE_ADDR 32 $LED3_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO1_SETDATAOUT 32 $LED3_VAL
				;;
			OFF)
				$DEVMEM $GPIO1_CLEARDATAOUT 32 $LED3_VAL
				;;
			*)
				print_help
				exit 1
				;; 
		esac
		;;
	*)
		print_help
		exit 1
		;;
esac 
echo "Done!"
exit 0


