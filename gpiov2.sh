# This Script help you turn on and off 6 LEDs over BeagleBone Blue.
# The work is done thanks to MR. Nasser Afshin and I just customize this for Beagle Bone 
# This is upgraded version of gpiov1.sh

#!/bin/sh
DEVMEM="/sbin/devmem"


GPIO1=0x4804C000
GPIO1_OE_ADDR=$((GPIO1+0x134))   	#Output enable register
GPIO1_CLEARDATAOUT=$((GPIO1+0x190))  	#Clear data out register
GPIO1_SETDATAOUT=$((GPIO1+0x194))   	#Set data out register

GPIO2=0x481AC000
GPIO2_OE_ADDR=$((GPIO2+0x134))   	#Output enable register
GPIO2_CLEARDATAOUT=$((GPIO2+0x190))  	#Clear data out register
GPIO2_SETDATAOUT=$((GPIO2+0x194))   	#Set data out register

LED0_VAL=0x00200000
LED1_VAL=0x00400000
LED2_VAL=0x00800000
LED3_VAL=0x01000000

LEDRED_VAL=0x00000004
LEDGRN_VAL=0x00000008

LED0_OE_VAL=0x00000000
LED1_OE_VAL=0x00000000
LED2_OE_VAL=0x00000000
LED3_OE_VAL=0x00000000

LEDRED_OE_VAL=0x00000000
LEDGRN_OE_VAL=0x00000000

LED0_OE_MASK=$(printf "0x%8x" $((~LED0_VAL & 0xFFFFFFFF)) ) #0xFFDFFFFF
LED1_OE_MASK=$(printf "0x%8x" $((~LED1_VAL & 0xFFFFFFFF)) ) #0xFFBFFFFF
LED2_OE_MASK=$(printf "0x%8x" $((~LED2_VAL & 0xFFFFFFFF)) ) #0xFF7FFFFF
LED3_OE_MASK=$(printf "0x%8x" $((~LED3_VAL & 0xFFFFFFFF)) ) #0xFEFFFFFF

LEDRED_OE_MASK=$(printf "0x%8x" $((~LEDRED_VAL & 0xFFFFFFFF)) ) #0xFFFFFFFB
LEDGRN_OE_MASK=$(printf "0x%8x" $((~LEDGRN_VAL & 0xFFFFFFFF)) ) #0xFFFFFFF7

print_help () {
	echo "Usage: $0 <LED1 | LED2 | LED3 | LED4 | LEDRED | LEDGRN> <ON | OFF>"
}

set_reg () {
	# $1: Address
	# $2: Length (bit)
	# $3: Value
	# $4: Mask
	VAL=$($DEVMEM $1 $2)
	let "VAL&=$3"
	let "VAL|=$4"
	$DEVMEM $1 $2 $VAL
}

if [ -z "$1" ]
then
	print_help
	exit 1
fi

echo "Setting GPIO $1 to $2 ..."
case $1 in
	LED0)
		set_reg $GPIO1_OE_ADDR 32 $LED0_OE_MASK $LED0_OE_VAL
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
	LED1)
		set_reg $GPIO1_OE_ADDR 32 $LED1_OE_MASK $LED1_OE_VAL
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
		set_reg $GPIO1_OE_ADDR 32 $LED2_OE_MASK $LED2_OE_VAL
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
		set_reg $GPIO1_OE_ADDR 32 $LED3_OE_MASK $LED3_OE_VAL
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
	LEDRED)
		set_reg $GPIO2_OE_ADDR 32 $LEDRED_OE_MASK $LEDRED_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO2_SETDATAOUT 32 $LEDRED_VAL
				;;
			OFF)
				$DEVMEM $GPIO2_CLEARDATAOUT 32 $LEDRED_VAL
				;;
			*)
				print_help
				exit 1
				;; 
		esac
		;;
	LEDGRN)
		set_reg $GPIO2_OE_ADDR 32 $LEDGRN_OE_MASK $LEDGRN_OE_VAL
		case $2 in
			ON)
				$DEVMEM $GPIO2_SETDATAOUT 32 $LEDGRN_VAL
				;;
			OFF)
				$DEVMEM $GPIO2_CLEARDATAOUT 32 $LEDGRN_VAL
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
